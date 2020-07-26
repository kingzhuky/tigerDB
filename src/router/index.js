//cdn 引入减
//import Vue from 'vue'

//cdn 引入减
//Vue.use(VueRouter)
//import VueRouter from 'vue-router'
const home = () => import('@/components/home/home')
const immuneResponse = () => import('@/components/immuneResponse/home')
const immuneSignature = () => import('@/components/immuneSignature')
const immuneScreen = () => import('@/components/immuneScreen')
const singleCellImmune = () => import('@/components/singleCellImmune/home')
const download = () => import('@/components/download')
const help = () => import('@/components/help')
const contact = () => import('@/components/contact')
const search = () => import('@/components/search/home')

export default new VueRouter({
  //mode: 'history',
  //base:'/m6a2target',
  routes: [{
      path: '/',
      component: home,
    },
    {
      path: '/home',
      name: 'home',
      component: home
    }, {
      path: '/immuneResponse',
      name: 'immuneResponse',
      component: immuneResponse
    }, {
      path: '/immuneSignature',
      name: 'immuneSignature',
      component: immuneSignature
    }, {
      path: '/singleCellImmune',
      name: 'singleCellImmune',
      component: singleCellImmune
    }, {
      path: '/immuneScreen',
      name: 'immuneScreen',
      component: immuneScreen
    },{
      path: '/search/:gene?',
      name: 'search',
      component: search
    }, {
      path: '/download',
      name: 'download',
      component: download
    },
    {
      path: '/help',
      component: help
    },
    {
      path: '/contact',
      component: contact
    }

  ],
  // srcollBehavior(to,from,savedPosition){
  //   if(to.hash){
  //     return {
  //       selector:to.hash
  //     }
  //   }
  // } 

})