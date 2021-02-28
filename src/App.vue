<template>
  <div id="app">
    <div id="app2" class="content">
      <div class="searchBar">
        <div>
          <el-row>
            <span id="title">
              <img id="home" src="./assets/home.jpg" />
            </span>
            <span id="subtitle">
              <span class="sub">T</span>umor
              <span class="sub">I</span>mmuno-therapy
              <span class="sub">G</span>ene
              <span class="sub">E</span>xpression
              <span class="sub">R</span>esource
            </span>
          </el-row>
        </div>

        <el-menu
          :default-active="activeIndex"
          id="haha"
          class="el-menu-demo"
          mode="horizontal"
          background-color="rgb(47, 175, 169)"
          text-color="black"
          active-text-color="#fff"
          router
        >
          <el-menu-item index="/home">
            <div class="header-nav">Home</div>
          </el-menu-item>
          <el-menu-item index="/singleCellImmune">
            <div class="header-nav">Single-cell Immunity</div>
          </el-menu-item>
          <el-menu-item index="/immuneResponse">
            <div class="header-nav">Immunotherapy Response</div>
          </el-menu-item>
          <el-menu-item index="/immuneSignature">
            <div class="header-nav">Response Signature</div>
          </el-menu-item>
          <el-menu-item index="/immuneScreen">
            <div class="header-nav">Immune Screening</div>
          </el-menu-item>
          <el-menu-item index="/search">
            <div class="header-nav">Search</div>
          </el-menu-item>
          <el-menu-item index="/help">
            <div class="header-nav">Help</div>
          </el-menu-item>
          <el-menu-item index="/download">
            <div class="header-nav">Download</div>
          </el-menu-item>
          <el-menu-item index="/contact">
            <div class="header-nav">Contact</div>
          </el-menu-item>
        </el-menu>
      </div>
      <div class="routercontent">
        <keep-alive>
          <router-view />
        </keep-alive>
      </div>
      <div id="snackbar" v-show="showSnackbar">
        Modern browsers (e.g.,
        <a target="_blank" href="https://www.google.com/chrome/">Chrome</a>,
        <a target="_blank" href="https://www.mozilla.org/">Firefox</a>,
        <a
          target="_blank"
          href="https://support.microsoft.com/en-us/help/4501095/download-the-new-microsoft-edge-based-on-chromium"
        >Edge</a>,
        <a target="_blank" href="https://www.apple.com/safari/">Safari</a>) are strongly recommended for a better experience!
        <el-button type="primary" @click="myFunction">Got it</el-button>
      </div>
    </div>
    <v-footer></v-footer>
  </div>
</template>

<script>
//cdn 引入加
Vue.use(VueLazyload);

export default {
  name: "app",
  data() {
    return {
      activeIndex: "1",
      isCollapse: false,
      showSnackbar: false,
    };
  },
  components:{
    "v-footer": () => import("./components/public/footer.vue"),
  },
  methods: {
    isIE() {
      //ie?
      if (!!window.ActiveXObject || "ActiveXObject" in window) {
        return true;
      } else {
        return false;
      }
    },
    myFunction() {
      this.showSnackbar = false;
    },
  },
  mounted() {
    if (this.isIE()) {
      this.showSnackbar = true;
      this.isActive = false;
    }
  },
};
</script>

<style>
#snackbar {
  min-width: 250px;
  margin-left: -125px;
  background-color: #333;
  color: #fff;
  text-align: center;
  border-radius: 2px;
  padding: 5px;
  position: fixed;
  z-index: 100000;
  left: 10%;
  bottom: 10px;
  font-size: 16px;
  animation: copacity 3s;
  -webkit-animation: copacity 3s;
}

.el-menu-item {
  padding: 0 9px !important;
}

.content {
  margin: 0 auto;
  background: rgb(255, 255, 255);
  width: 1398px;
}

.el-menu-demo {
  z-index: 100;
  width: 1398px;
}
.header-nav {
  font-size: 18px !important;
  font-weight: bold;
  width: 100%;
  border: 20px;
}

i.el-icon-setting {
  padding-left: 10px;
  font-size: 25px;
  color: rgb(20, 146, 140);
}

.routercontent {
  padding-top: 140px;
}

#app {
  position: relative;
  min-height: 100%;
  padding-bottom: 50px;
  box-sizing: border-box;
  background: rgb(245, 248, 249);
  height: auto;
  overflow-y: visible;
}

.searchBar {
  width: 1398px;
  position: fixed;
  background: white;
  z-index: 10000;
}

html,
body {
  font-family: Arial !important;
  margin: 0;
  padding: 0;
  height: 100%;
  margin-bottom: 60px;
}

.el-divider--horizontal {
  margin: 8px 0 15px 0 !important;
}
img#home {
  width: 180px;
  margin-bottom: -8px;
  padding-right: 20px;
  padding-left: 10px;
}
#title {
  color: #14928c !important;
  font-size: 40px;
  font-weight: 700;
}
#subtitle {
  font-size: 26px;
  font-weight: 550;
}
span.sub {
  color: rgb(20, 146, 140) !important;
}

.box-card-return {
  background-color: rgb(154 202 200) !important;
}
</style>
