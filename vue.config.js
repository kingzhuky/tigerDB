var path = require('path');
const CompressionWebpackPlugin  = require('compression-webpack-plugin')
const productionGzipExtensions = ['js', 'css']

const isProd = process.env.NODE_ENV === 'production'

var proEnv = require('./config/pro.env');  // 生产环境
var devEnv = require('./config/dev.env');  // 本地环境
const env = process.env.NODE_ENV;
let target = '';
// 默认是本地环境
if(env==='production'){  // 生产环境
  target = proEnv.hosturl;
  dgidb = proEnv.dgidb;
  m6a2target=proEnv.m6a2target;
}else{  // 本地环境
  target = devEnv.hosturl;
  dgidb = devEnv.dgidb;
  m6a2target=devEnv.m6a2target;
}
// 生成代理配置对象
let proxyObj = {};
proxyObj['/tiger/*'] = {
    target: target,
    changeOrigin: true,
    pathRewrite: {
        '^/tiger':'/tiger' //路径无api 所以重写为空
    }
};

proxyObj['/dgidb/*'] = {
  target: dgidb,
  changeOrigin: true,
  pathRewrite: {
      '^/dgidb':'/' //路径无api 所以重写为空
  }
};

proxyObj['/m6a2target/*'] = {
  target: m6a2target,
  changeOrigin: true,
  pathRewrite: {
      '^/m6a2target':'/' 
  }
};



module.exports = {
  // 基本路径
  publicPath: './',
  // 输出文件目录
  outputDir: 'dist',
  // eslint-loader 是否在保存的时候检查
  lintOnSave: true,
  // webpack配置
  chainWebpack: () => { },
  configureWebpack:  config => {
    //if (isProd) {
      config.plugins.push(new CompressionWebpackPlugin({
        algorithm: 'gzip',
        test: new RegExp('\\.(' + productionGzipExtensions.join('|') + ')$'),
        threshold: 10240,
        minRatio: 0.8
      })
      ),
      config.externals = {
        'vue': 'Vue', //cdn 引入加
        'axios':'axios',
        'vue-router': 'VueRouter',
        'vue-lazyload':'vue-lazyload',
        'element-ui': 'ELEMENT',
        'echarts':'echarts'


      }
    //}
  },
  // 生产环境是否生成 sourceMap 文件
  productionSourceMap: false,
  // css相关配置
  css: {
      // 是否使用css分离插件 ExtractTextPlugin
      extract: true,
      // 开启 CSS source maps?
      sourceMap: false,
      // css预设器配置项
      loaderOptions: {
        // postcss: {
        //   // 这是rem适配的配置  注意： remUnit在这里要根据lib-flexible的规则来配制，如果您的设计稿是750px的，用75就刚刚好。
        //   plugins: [
        //     require("postcss-pxtorem")({
        //       rootValue : 200,
        //       "propList": ["*"]
        //     })
        //   ]
        // }
  
      },
      // 启用 CSS modules for all css / pre-processor files.
      modules: false
  },
  parallel: require('os').cpus().length > 1,
  pwa: {},
  // webpack-dev-server 相关配置
  devServer: {
      open: true,                                 //配置自动启动浏览器
      host: 'localhost',
      port: 8080,                                 // 端口号
      https: false,
      hotOnly: false, 
      // https:{type:Boolean}
      // proxy: {                                        // 配置跨域
      //     '/api/*':{
      //         target:'http://localhost:8090/', //源地址
      //         changeOrigin:true,                  //改变源
      //         ws:true,                            //是否代理websockets
      //         pathRewrite:{
      //             '^/api':'/'
      //         }
      //     },
      //     '/igvurl':{
      //       target: 'http://127.0.0.1:8080',
      //       changeOrigion: true
      //   }
      // },                                           // 配置跨域处理,只有一个代理
      proxy:proxyObj,
      before: app => { }
  },
  // 第三方插件配置
  pluginOptions: {}
}