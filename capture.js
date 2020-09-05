// require('dotenv').config();
//
// const puppeteer = require('puppeteer');
// const AWS = require('aws-sdk');
// const BUCKET_REGION = 'ap-northeast-1';
// var mysql = require('mysql');
//
// // 定数 (後述)
// const LOGIN_URL = process.env.KURUMESI_MANAGE_URL;
// const LOGIN_USER = process.env.KURUMESI_LOGIN_ID;
// const LOGIN_PASS = process.env.KURUMESI_LOGIN_PASS;
// const LOGIN_USER_SELECTOR = '#login > article > form > ul > li:nth-child(1) > input';
// const LOGIN_PASS_SELECTOR = '#login > article > form > ul > li:nth-child(2) > input';
// const LOGIN_SUBMIT_SELECTOR = '#login > article > form > p > input[type=submit]';
// const SAVE_BUCKET_NAME = process.env.KURUMESI_ORDER_BUCKET_NAME;
//
// function getNowYMD(){
//   var dt = new Date();
//   var y = dt.getFullYear();
//   var m = ("00" + (dt.getMonth()+1)).slice(-2);
//   var d = ("00" + dt.getDate()).slice(-2);
//   var result = y + "-" + m + "-" + d;
//   // var result = '2020-03-31';
//   return result;
// }
//
// /**
//  * メイン処理です。
//  */
// (async () => {
//     var date = getNowYMD();
//     var management_ids = [];
//     var pool = mysql.createPool({
//         host: process.env.MYSQL_HOST,
//         user: process.env.MYSQL_USER,
//         password: process.env.MYSQL_PASS,
//         database: process.env.MYSQL_DATABASE
//     });
//     pool.getConnection(function(err, connection){
//       connection.query('SELECT * from kurumesi_orders WHERE start_time >= "'+ date +'" AND canceled_flag = "false" AND capture_done = 0', function (err, rows, fields) {
//         if (err) { console.log('err: ' + err); }
//         rows.map(function( value ) {
//           management_ids.push(value.management_id);
//         });
//         console.log(management_ids);
//       });
//
//       connection.query('UPDATE kurumesi_orders SET capture_done = 1 WHERE start_time >= "'+ date +'" AND canceled_flag = "false" AND capture_done = 0', function(error, response) {
//         if (err) { console.log('err: ' + err); }
//         console.log(response);
//         // connection.release();
//         connection.destroy();
//       });
//     });
//     const browser = await puppeteer.launch({
//       headless: true, // ブラウザを表示するか (デバッグの時は false にしたほうが画面が見えてわかりやすいです)
//       args: [
//         '--enable-font-antialiasing',
//         '--no-sandbox',
//         '--disable-setuid-sandbox'
//       ]
//     })
//
//     const page = await browser.newPage(); // 新規ページ
//     await page.setViewport({ width: 800, height: 9999 }); // ビューポート (ウィンドウサイズ)
//     await page.setExtraHTTPHeaders({ // 必要な場合、HTTPヘッダを追加
//         'Accept-Language': 'ja'
//     });
//
//     // ログイン画面でログイン
//     await page.goto(LOGIN_URL, { waitUntil: 'domcontentloaded' });
//     await page.type(LOGIN_USER_SELECTOR, LOGIN_USER); // ユーザー名入力
//     await page.type(LOGIN_PASS_SELECTOR, LOGIN_PASS); // パスワード入力
//     await Promise.all([ // ログインボタンクリック
//       // クリック後ページ遷移後通信が完了するまで待つ (ページによっては 'domcontentloaded' 等でも可)
//       page.waitForNavigation({ waitUntil: 'networkidle0' }),
//       page.click(LOGIN_SUBMIT_SELECTOR),
//     ]);
//
//     const targetElementSelector = '#order > div > article > section:nth-child(1)'
//     await page.waitFor(targetElementSelector)
//
//     for(let i of management_ids) {
//
//       //弁当内訳部分のスクショ
//       var id = String(i)
//       await page.goto(process.env.KURUMESI_MANAGE_ORDERDETAIL_URL+ id +'/');
//       const filename = id
//       const clip = await page.evaluate(s => {
//         const el = document.querySelector(s)
//         const { width, height, top: y, left: x } = el.getBoundingClientRect()
//         return { width, height, x, y }
//       }, targetElementSelector)
//       const jpgBuf = await page.screenshot({ clip, type: 'jpeg'  })
//       AWS.config.loadFromPath('rootkey.json');
//       const s3 = new AWS.S3();
//       let s3Param = {
//           Bucket: SAVE_BUCKET_NAME,
//           Key: null,
//           Body: null
//       };
//       s3Param.Key = filename + '.jpg';
//       s3Param.Body =  jpgBuf;
//       await s3.putObject(s3Param).promise();
//
//       // 請求書のスクショ
//       const accounting_checked = await page.$('form[name="form1"]').then(res => !!res);
//       if (accounting_checked) {
//         const [newPage] = await Promise.all([
//           browser.waitForTarget(t => t.opener() === page.target()).then(t => t.page()),
//           page.click('form[name="form1"] > input[type=submit]:nth-child(1)')
//         ]);
//         await newPage.setViewport({ width: 900, height: 1500 }); // ビューポート (ウィンドウサイズ)
//         await newPage.waitForSelector('#main > div > p.delivery_notes', {visible: true});
//         const jpgBuf_2 = await newPage.screenshot({ type: 'png'  })
//         AWS.config.loadFromPath('rootkey.json');
//         const s3_2 = new AWS.S3();
//         let s3_2Param = {
//             Bucket: 'accounting-screenshot',
//             Key: null,
//             Body: null
//         };
//         s3_2Param.Key = filename + '.png';
//         s3_2Param.Body =  jpgBuf_2;
//         await s3_2.putObject(s3_2Param).promise();
//         console.log('請求書保存');
//         await newPage.close();
//       };
//       // 納品書のスクショ
//       const deli_checked = await page.$('form[name="form2"]').then(res => !!res);
//       if (deli_checked) {
//         const [newPage3] = await Promise.all([
//           browser.waitForTarget(t => t.opener() === page.target()).then(t => t.page()),
//           page.click('form[name="form2"] > input[type=submit]:nth-child(1)')
//         ]);
//         await newPage3.setViewport({ width: 900, height: 1500 }); // ビューポート (ウィンドウサイズ)
//         await newPage3.waitForSelector('#main > div > table:nth-child(9)', {visible: true});
//         const jpgBuf_3 = await newPage3.screenshot({ type: 'png'  })
//         AWS.config.loadFromPath('rootkey.json');
//         const s3_3 = new AWS.S3();
//         let s3_3Param = {
//             Bucket: 'kurumesi-delivery-note',
//             Key: null,
//             Body: null
//         };
//         s3_3Param.Key = filename + '.png';
//         s3_3Param.Body =  jpgBuf_3;
//         await s3_3.putObject(s3_3Param).promise();
//         console.log('納品書保存');
//         await newPage3.close();
//       };
//     };
//     // ブラウザを閉じる
//     await browser.close();
// })();
