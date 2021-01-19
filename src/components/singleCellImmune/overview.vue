<template>
  <transition name="move3">
    <div class="detail-card" v-loading="loading" >
      <div>
        <el-card>
          <p class="card-title">Dataset Information</p>
        </el-card>
      </div>
      <div class="infor">
        <el-card v-for="gloclu in gloclures" :key="gloclu" overflow="auto" class="overiewcard">
          <p class="card-title">{{gloclu}}&nbsp;&nbsp;&nbsp;&nbsp;{{cellnum[gloclu]}}</p>
          <el-row class="detailimg" type="flex" justify="center" >
            <el-col :span="6" style="position:relative;right:10px;top:20px;">
              <p class="imgtitle">Cell Types</p>
              <img
                id="singleimg"
                fit="fill"
                width="250px"
                :src="'tiger/img/'+plotsres[gloclu][0]+'.png'" 
                @click="previewImg(['tiger/img/'+plotsres[gloclu][0]+'.png','tiger/img/'+plotsres[gloclu][1]+'.png','tiger/img/'+plotsres[gloclu][2]+'.png','tiger/img/'+plotsres[gloclu][3]+'.png'])">
            </el-col>
            <el-col v-show="typeof(plotsres[gloclu][1]) === 'undefined' ? false: true" :span="6" :offset="0" style="position:relative;right:40px;top:20px;">
              <p class="imgtitle">Cell Fraction</p>
              <img
                id="singleimg"
                fit="fill"
                width="300px"
                :src="'tiger/img/'+plotsres[gloclu][1]+'.png'" 
                @click="previewImg(['tiger/img/'+plotsres[gloclu][1]+'.png','tiger/img/'+plotsres[gloclu][2]+'.png','tiger/img/'+plotsres[gloclu][3]+'.png','tiger/img/'+plotsres[gloclu][0]+'.png'])">
            </el-col>
            <el-col v-show="typeof(plotsres[gloclu][2]) === 'undefined' ? false: true" :span="6" :offset="0" style="position:relative;right:30px;top:20px;">
              <p class="imgtitle">Group Difference of Each Cluster</p>
              <img
                id="singleimg"
                fit="fill"
                width="300px"
                :src="'tiger/img/'+plotsres[gloclu][2]+'.png'" 
                @click="previewImg(['tiger/img/'+plotsres[gloclu][2]+'.png','tiger/img/'+plotsres[gloclu][3]+'.png','tiger/img/'+plotsres[gloclu][0]+'.png','tiger/img/'+plotsres[gloclu][1]+'.png'])">
            </el-col>
            <el-col v-show="typeof(plotsres[gloclu][3]) === 'undefined' ? false: true" :span="6" :offset="0" style="position:relative;right:20px;top:20px;">
              <p class="imgtitle">Classical Cell Markers</p>
              <img
                id="singleimg"
                fit="fill"
                width="350px"
                :src="'tiger/img/'+plotsres[gloclu][3]+'.png'" 
                @click="previewImg(['tiger/img/'+plotsres[gloclu][3]+'.png','tiger/img/'+plotsres[gloclu][0]+'.png','tiger/img/'+plotsres[gloclu][1]+'.png','tiger/img/'+plotsres[gloclu][2]+'.png'])">
            </el-col>
          </el-row>
        </el-card>
      </div>

      <v-goTop></v-goTop>
    </div>
  </transition>
</template>

<script>
import goTop from "../public/goTop";

export default {
  props: {
    gloclu: String,
    cancer: String,
    gloCluoptions: Array,
  },

  data() {
    return {
      scimmuShow: false,
      scimmuresShow: false,
      loading: true,
      crossloading: false,
      seargene: "HLA-A_CD3G",
      restaurants: [],
      crossClucoptions: [],
      crossClu: [],
      gloclures: [],
      plotsres: {},
      cellnum: {},
    };
  },

  mounted() {
    this.clickPlot();
  },
  methods: {
    querySearchAsync(queryString, cb) {
      var restaurants = this.restaurants;
      var results = queryString
        ? restaurants.filter(this.createStateFilter(queryString))
        : restaurants;
      cb(results);
    },

    createStateFilter(queryString) {
      return (restaurant) => {
        return (
          restaurant.value.toLowerCase().indexOf(queryString.toLowerCase()) ===
          0
        );
      };
    },

    reset() {
      (this.gloclures = []), (this.plotsres = {});
    },

    checkdataset() {
      if (
        (Array.isArray(this.crossClu) && this.crossClu.length === 0) ||
        this.seargene.trim() === ""
      ) {
        return true;
      }
      return false;
    },
    clickPlot() {
      this.reset();
      console.log(this.cancer)
      this.loading = true;
      var glocluindex = [];
      this.$http
        .get("/tiger/scglocluster.php", {
          params: {
            cancer: this.cancer,
            type: "homescinfo",
          },
        })
        .then((res) => {
          this.gloCluoptions = res.data.list;
          console.log(this.gloCluoptions)
          // let count = 0;
          let plotflag = 0;
          for (let gloclu of this.gloCluoptions) {
            // console.log("loop: ")
            // console.log(gloclu["GlobalCluster"])
            glocluindex.push(gloclu["GlobalCluster"])
            this.Plot(this.cancer, gloclu["GlobalCluster"]).then((value) => {
              plotflag++
              // console.log(plotflag)
              // console.log("Max type: " + Object.keys(this.gloCluoptions).length)
              if(plotflag == Object.keys(this.gloCluoptions).length){
                this.gloclures = glocluindex;
                this.loading = false;
                console.log(this.gloclures)
              }
            })
          }
        });
    },

    async Plot(cancer, gloclu) {
      var that = this;
      // that.loading = true;
      return new Promise(resolve => {
        this.$http
          .get("/tiger/singlecellimmu.php", {
            params: {
              cancer: cancer,
              gloclu: gloclu,
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              // console.log(that.loading)
              // console.log(gloclu)
              // that.gloclures.push(gloclu);
              that.plotsres[gloclu] = res.data.output[0].split(",");
              console.log(res.data.cellnum[0].split(","))
              resolve(res.data.output[0].split(","))
              that.cellnum[gloclu] = res.data.cellnum[0].replace(/,/g," ")
              // console.log(that.plotsres[gloclu][1])
              // that.loading = false;
            }
          })
          .catch(function (res) {
            resolve(console.log(res))
          });
      });
    },

    previewImg(urlList){
      this.$hevueImgPreview({
        multiple: true, // 开启多图预览模式
        keyboard: true,
        nowImgIndex: 0, // 多图预览，默认展示第二张图片
        imgList: urlList, // 需要预览的多图数组
        mainBackground: 'rgba(0, 0, 0, .5)', // 整体背景颜色
      })
    }
  },

  components: {
    "v-goTop": goTop,
  },
};
</script>

<style>
.overiewcard {
  margin-top: 20px;
}

div#pane-overview {
  font-size: 16px;
}
#scummuviewer {
  margin-top: 15px;
}
div#viewerSelect {
  text-align: center;
}
#scimmubt {
  background-color: rgb(20, 146, 140) !important;
  font-weight: bold;
  color: white !important;
  width: 100%;
}
#homespan {
  color: rgb(20, 146, 140) !important;
  font-size: 20px;
}

div#crossplot {
  padding-top: 40px;
}
</style>


