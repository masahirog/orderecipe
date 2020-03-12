require('dotenv').config();

const puppeteer = require('puppeteer');
var mysql = require('mysql');

// 定数 (後述)
const LOGIN_URL = process.env.KURUMESI_MANAGE_URL;
const LOGIN_USER = process.env.KURUMESI_LOGIN_ID;
const LOGIN_PASS = process.env.KURUMESI_LOGIN_PASS;
const LOGIN_USER_SELECTOR = '#login > article > form > ul > li:nth-child(1) > input';
const LOGIN_PASS_SELECTOR = '#login > article > form > ul > li:nth-child(2) > input';
const LOGIN_SUBMIT_SELECTOR = '#login > article > form > p > input[type=submit]';

function getNowYMD(){
  var dt = new Date();
  dt.setDate(dt.getDate() + 1);
  return dt
}


function dbconect(connection,hour,minute,management_id,u,err,len){
  connection.query('UPDATE kurumesi_orders SET pick_time = "'+hour+':'+minute+':'+'00" WHERE management_id = "'+ management_id +'"', function(error, response) {
    if (err) { console.log('err: ' + err); }
    console.log(response);
    console.log(u);
    if (u == len) {
      connection.destroy();
    }
  });
}

/**
 * メイン処理です。
 */
(async () => {
    var dt = getNowYMD();
    var y = dt.getFullYear();
    var m = ("00" + (dt.getMonth()+1)).slice(-2);
    var d = ("00" + dt.getDate()).slice(-2);
    var date = y + "-" + m + "-" + d;
    console.log(date);
    var management_ids = [];
    var arr = [];
    var pool = mysql.createPool({
        host: process.env.MYSQL_HOST,
        user: process.env.MYSQL_USER,
        password: process.env.MYSQL_PASS,
        database: process.env.MYSQL_DATABASE
    });
    // var pool = mysql.createPool({
    //     host     : 'localhost',
    //     user     : 'root',
    //     password : '',
    //     database : 'orderecipe_development'
    // });

    pool.getConnection(function(err, connection){
      connection.query('SELECT * from kurumesi_orders WHERE start_time = "'+ date +'" AND canceled_flag = "false"', function (err, rows, fields) {
        if (err) { console.log('err: ' + err); }
        rows.map(function( value ) {
          management_ids.push( value.management_id );
        });
        console.log(management_ids);
        connection.destroy();
      });

    });
    const browser = await puppeteer.launch({
      headless: true, // ブラウザを表示するか (デバッグの時は false にしたほうが画面が見えてわかりやすいです)
      args: [
        '--enable-font-antialiasing',
        '--no-sandbox',
        '--disable-setuid-sandbox'
      ]
    })

    const page = await browser.newPage(); // 新規ページ
    await page.setViewport({ width: 800, height: 1000 }); // ビューポート (ウィンドウサイズ)
    await page.setExtraHTTPHeaders({ // 必要な場合、HTTPヘッダを追加
        'Accept-Language': 'ja'
    });

    // ログイン画面でログイン
    await page.goto(LOGIN_URL, { waitUntil: 'domcontentloaded' });
    await page.type(LOGIN_USER_SELECTOR, LOGIN_USER); // ユーザー名入力
    await page.type(LOGIN_PASS_SELECTOR, LOGIN_PASS); // パスワード入力
    await Promise.all([ // ログインボタンクリック
        // クリック後ページ遷移後通信が完了するまで待つ (ページによっては 'domcontentloaded' 等でも可)
        page.waitForNavigation({ waitUntil: 'networkidle0' }),
        page.click(LOGIN_SUBMIT_SELECTOR),
    ]);

    // ログイン後の画面に移動
    for(var i = 1;i<5;i++) {
      await page.goto("http://admin.kurumesi-bentou.com/admin_shop/order/?action=SearchOrder&delivery_yy_s="+y+"&delivery_mm_s="+m+"&delivery_dd_s="+d+"&delivery_yy_e="+y+"&delivery_mm_e="+m+"&delivery_dd_e="+d+"&order_status=1&page="+String(i));
      var orders = await page.$$('.detail');
      if (await page.$('.detail').then(res => !!res)) {
        for (let i = 0; i < orders.length; i++) {
          var management_id = await orders[i].$eval('input[name="pickup_order_no"]', el => el.value);
          var hour = await orders[i].$eval('select[name="pickup_time_hh"]', el => el.value);
          var minute = await orders[i].$eval('select[name="pickup_time_ii"]', el => el.value);
          console.log([management_id,hour,minute]);
          arr.push( [management_id,hour,minute] );
        }
      }else{
        console.log('out');
        break;
      };
    }
    await browser.close();
    var u = 0;
    pool.getConnection(function(err, connection){
      arr.map(function( i ) {
        u += 1
        var management_id = i[0];
        var hour = i[1];
        var minute = i[2];
        dbconect(connection,hour,minute,management_id,u,err,arr.length);
      });
    });

})();
