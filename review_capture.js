// require('dotenv').config();
// var dt = new Date();
// var mysql = require('mysql');
// const puppeteer = require('puppeteer');
// const AWS = require('aws-sdk');
// var KURUMESIURL = "https://www.kurumesi-bentou.com/"
// const BUCKET_REGION = 'ap-northeast-1';
// const SAVE_BUCKET_NAME = 'review-captures';
//
// (async () => {
//   var reviews = [];
//   var brands_arr = [];
//   var pool = mysql.createPool({
//       host: process.env.MYSQL_HOST,
//       user: process.env.MYSQL_USER,
//       password: process.env.MYSQL_PASS,
//       database: process.env.MYSQL_DATABASE
//   });
//   // var pool = mysql.createPool({
//   //     host     : 'localhost',
//   //     user     : 'root',
//   //     password : '',
//   //     database : 'orderecipe_development'
//   // });
//
//
//   pool.getConnection(function(err, connection){
//     connection.query('SELECT * from brands WHERE kurumesi_flag = 1', function (err, brands, fields) {
//       if (err) { console.log('err: ' + err); }
//       brands_arr = brands
//       connection.destroy();
//     });
//   });
//
//
//   const viewportHeight = 1500
//   const viewportWidth = 999999
//   const browser = await puppeteer.launch({
//     headless: true, // ブラウザを表示するか (デバッグの時は false にしたほうが画面が見えてわかりやすいです)
//     args: [
//       '--enable-font-antialiasing',
//       '--no-sandbox',
//       '--disable-setuid-sandbox'
//     ]
//   });
//   const page = await browser.newPage();
//   await page.setViewport({ width: viewportHeight, height:viewportWidth });
//   await page.setExtraHTTPHeaders({
//       'Accept-Language': 'ja'
//   });
//
//
//   for(var i=0;i<brands_arr.length;i++){
//     var brand_id = brands_arr[i].id;
//     var titles = [];
//     console.log(brand_id);
//     pool.getConnection(function(err, connection){
//       connection.query('SELECT * from reviews WHERE brand_id = ' + String(brand_id) , function (err, rows, fields) {
//         if (err) { console.log('err: ' + err); }
//         reviews = rows;
//         rows.map(function( value ) {
//           titles.push( value.title );
//         });
//         connection.destroy();
//       });
//     });
//
//     var kurumesi_review_url = KURUMESIURL + brands_arr[i].store_path + "/review/";
//     await page.goto(kurumesi_review_url, { waitUntil: 'domcontentloaded' });
//     await page.waitFor(5000);
//     var kurumesi_reviews = await page.$$('.review-wrapper__item');
//     var targetElementSelector_before = '#content > div.inner.clearfix > div > div.shopContent > div > div.review > ul > li:nth-child(';
//     for (let i = 0; i < kurumesi_reviews.length; i++) {
//       var title = await kurumesi_reviews[i].$eval('.review-main__ttl', el => el.textContent);
//       if (titles.indexOf(title) >= 0) {
//       }else{
//         var post = await kurumesi_reviews[i].$eval('.review-main__comment', el => el.textContent);
//         var delivery_date = await kurumesi_reviews[i].$eval('p.review-info__date', el => el.textContent);
//         var address = await kurumesi_reviews[i].$eval('p.review-info__area', el => el.textContent);
//         var use_scenes = await kurumesi_reviews[i].$$eval('li.scene-detail__item', list => {
//           return list.map(data => data.textContent.replace(/\s+/g, '').substr(data.textContent.replace(/\s+/g, '').indexOf(":")+1));
//         });
//         var use_scene = use_scenes[0];
//         var age = use_scenes[1];
//         var score = await kurumesi_reviews[i].$eval('.rate-main__num', el => el.textContent);
//         var filename = String(brand_id)+"_"+delivery_date.replace(/\u002f/g, "") +"_"+ address;
//         pool.getConnection(function(err, connection){
//           const review = {brand_id:brand_id, delivery_date:delivery_date,delivery_area:address,title:title,post:post,use_scene:use_scene,age:age,score:score,created_at:dt,updated_at:dt};
//           connection.query('INSERT INTO reviews SET ?',review , function(error, response) {
//             if(error) throw error;
//             console.log(response);
//             connection.destroy();
//           });
//         });
//         var targetElementSelector = targetElementSelector_before + String(i + 1) +")";
//         const clip = await page.evaluate(s => {
//           const el = document.querySelector(s)
//           const { width, height, top: y, left: x } = el.getBoundingClientRect()
//           return { width, height, x, y }
//         }, targetElementSelector)
//         const jpgBuf = await page.screenshot({ clip, type: 'jpeg'  })
//         AWS.config.loadFromPath('rootkey.json');
//         const s3 = new AWS.S3();
//         let s3Param = {
//             Bucket: SAVE_BUCKET_NAME,
//             Key: null,
//             Body: null
//         };
//         s3Param.Key = filename + '.jpg';
//         s3Param.Body =  jpgBuf;
//         await s3.putObject(s3Param).promise();
//       }
//     }
//   }
//   await browser.close();
// })();
