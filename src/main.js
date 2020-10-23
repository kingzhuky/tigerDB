//cdn 引入减

import Vue from 'vue'
// import axios from 'axios'
// import VueLazyload from 'vue-lazyload'
// Vue.use(VueLazyload)


// import 'element-ui/lib/theme-chalk/index.css';
// import {  Collapse, CollapseItem,Slider,Radio,Button,Select,Menu,MenuItem,Row,Col,Card,Option,Autocomplete,Input,Table,TableColumn,Submenu,Tabs,TabPane,OptionGroup,FormItem,Loading,Divider} from 'element-ui'
// import locale from 'element-ui/lib/locale/'
// import lang from 'element-ui/lib/locale/lang/en';

// Vue.use(Collapse);
// Vue.use(CollapseItem);
// Vue.use(Radio);
// Vue.use(Slider);
// Vue.use(Button);
// Vue.use(Select);
// Vue.use(Menu);
// Vue.use(MenuItem);
// Vue.use(Row);
// Vue.use(Col);
// Vue.use(Card);
// Vue.use(Option);
// Vue.use(Autocomplete);
// Vue.use(Input);
// Vue.use(Table);
// Vue.use(TableColumn);
// Vue.use(Submenu);
// Vue.use(Tabs);
// Vue.use(TabPane);
// Vue.use(OptionGroup);
// Vue.use(FormItem);
// Vue.use(Divider);
// Vue.use(Loading.directive);
// Vue.prototype.$loading = Loading.service;
// locale.use(lang)

// import echarts from 'echarts'
// Vue.prototype.$echarts = echarts

//cdn加
import ELEMENT from 'element-ui'
Vue.use(ELEMENT)
ELEMENT.locale(ELEMENT.lang.en)


//不变
Vue.prototype.$http = axios
import App from './App.vue'
import router from './router'
Vue.config.productionTip = false

import '../static/css/theme/index.css'
import hevueImgPreview from 'hevue-img-preview'
Vue.use(hevueImgPreview)

Vue.directive('loadmore', {
  bind(el, binding) {
    const selectWrap = el.querySelector('.el-table__body-wrapper')
    selectWrap.addEventListener('scroll', function () {
      let sign = 50
      const scrollDistance = this.scrollHeight - this.scrollTop - this.clientHeight
      if (scrollDistance <= sign) {
        binding.value()
      }
    })
  }
})

Vue.directive('loadlast', {
  bind(el, binding) {
    const selectWrap = el.querySelector('.el-table__body-wrapper')
    selectWrap.addEventListener('scroll', function () {
      let sign = 0
      if ( this.scrollTop === sign) {
        binding.value()
      }
    })
  }
})

//路由跳转
router.afterEach(() => {
  window.scrollTo(0, 0);
})


new Vue({
  router,
  render: h => h(App),
}).$mount('#app')