const puppeteer = require('puppeteer');
const AWS = require('aws-sdk');
const BUCKET_REGION = 'ap-northeast-1';
var mysql = require('mysql');

// 定数 (後述)
const LOGIN_URL = 'http://admin.kurumesi-bentou.com/admin_shop/order/';
const LOGIN_USER = '759';
const LOGIN_PASS = 'bchimBS9';
const LOGIN_USER_SELECTOR = '#login > article > form > ul > li:nth-child(1) > input';
const LOGIN_PASS_SELECTOR = '#login > article > form > ul > li:nth-child(2) > input';
const LOGIN_SUBMIT_SELECTOR = '#login > article > form > p > input[type=submit]';
const SAVE_BUCKET_NAME = 'kurumesi-check';


/**
 * スクリーンショットのファイル名を取得します。
 * @returns YYYYMMDD-HHMMSS.png 形式の文字列
 */


 function getNowYMD(){
   var dt = new Date();
   var y = dt.getFullYear();
   var m = ("00" + (dt.getMonth()+1)).slice(-2);
   var d = ("00" + dt.getDate()).slice(-2);
   var result = y + "-" + m + "-" + d;
   return result;
 }

/**
 * メイン処理です。
 */
(async () => {
    var connection = mysql.createConnection({
        host: 'us-cdbr-iron-east-05.cleardb.net',
        user: 'b1f4d8a73d3cd4',
        password: '60eee22d',
        database: 'heroku_cb0ea8c2b9342bf'
    });
    var date = getNowYMD();
    var management_ids = [];
    connection.query('SELECT * from kurumesi_orders WHERE start_time = "'+ date +'" AND canceled_flag = "false"', function (err, rows, fields) {
      if (err) { console.log('err: ' + err); }
      rows.forEach(function( value ) {
        management_ids.push( value.management_id );
      });
    });

    const browser = await puppeteer.launch({ // ブラウザを開く
        headless: true, // ブラウザを表示するか (デバッグの時は false にしたほうが画面が見えてわかりやすいです)
    });
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

    const targetElementSelector = '#order > div > article > section:nth-child(1)'
    await page.waitFor(targetElementSelector)

    // ログイン後の画面に移動
    for(let i of management_ids) {
      var id = String(i)
      console.log('http://admin.kurumesi-bentou.com/admin_shop/order_detail/'+ id +'/');
      await page.goto('http://admin.kurumesi-bentou.com/admin_shop/order_detail/'+ id +'/');
      const filename = id

      const clip = await page.evaluate(s => {
        const el = document.querySelector(s)

        // エレメントの高さと位置を取得
        const { width, height, top: y, left: x } = el.getBoundingClientRect()
        return { width, height, x, y }
      }, targetElementSelector)

      const jpgBuf = await page.screenshot({ clip, type: 'jpeg'  })
      AWS.config.loadFromPath('rootkey.json');
      const s3 = new AWS.S3();
      let s3Param = {
          Bucket: SAVE_BUCKET_NAME,
          Key: null,
          Body: null
      };
      s3Param.Key = filename + '.jpg';
      s3Param.Body =  jpgBuf;
      await s3.putObject(s3Param).promise();
    };
    // ブラウザを閉じる
    await browser.close();
    await connection.destroy();
})();
