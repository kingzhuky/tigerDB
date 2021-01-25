<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor" v-loading="artloading">
        <el-card >
          <p class="card-title">Dataset Information</p>
          <el-table :data="articleData" v-loading="artloading">
              <!-- <el-table-column prop="title" label width="180"></el-table-column> -->
            <el-table-column prop="title" label width="250">
                <template slot-scope="{row: {title}}">
                <span v-if="title === 'datasetid'">Dataset ID</span>
                <span v-else-if="title === 'datasetname'">Dataset Name</span>
                <span v-else-if="title === 'cancertype'">Cancer Type</span>
                <span v-else-if="title === 'platform'">Sequencing Platform</span>
                <span v-else-if="title === 'title'">Ariticle Title</span>
                <span v-else-if="title === 'cellnum'">Cell Number</span>
                <span v-else-if="title === 'patientnum'">Patient Number</span>
                <span v-else-if="title === 'samplenum'">Sample Number</span>
                <span v-else-if="title === 'tissue'">Tissue Number</span>
                <span v-else-if="title === 'checkpointtreatment'">Immunotherapy</span>
                <span v-else-if="title === 'response'">Immunotherapy Response</span>
                <span v-else-if="title === 'sorting'">Cell Sorting</span>
                <span v-else-if="title === 'pmid'">PMID</span>
                <span v-else-if="title === 'glo'">Differential Type</span>
                <span v-else>{{title}}</span>
                </template>
            </el-table-column>
            <el-table-column label>
                <template slot-scope="scope">
                <span v-if="scope.row.title === 'pmid'">
                    <a :href="'https://pubmed.ncbi.nlm.nih.gov/'+scope.row.value"
                    target="_blank"
                    class="buttonText">{{scope.row.value}}</a>
                    </span>
                <span v-else><a v-html="scope.row.value"></a></span>
                </template>
            </el-table-column>
          </el-table>
        </el-card>
      </div>
      <div v-if="loading">
        <br />
        <br />
        <br />
      </div>
      <div class="infor" style="margin-top: -20px" v-loading="loading">
        <el-card v-for="gloclu in gloclures" :key="gloclu" overflow="auto" class="overiewcard" >
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
      articleData: [],
      artloading: true,
      plotloading: true,
    };
  },

  mounted() {
    this.clickPlot();
  },
  methods: {
    articleDetail() {
      var that = this;
      that.artloading = true;
      this.$http
        .get("/tiger/immunescreendetail2.php", {
          params: {
            tabl: "scrnaseqinfo",
            colu: "datasetid",
            coluvalue: this.cancer,
          },
        })
        .then(function (res) {
          that.articleData = res.data.list;
          that.artloading = false;
        })
        .catch(function (res) {
          console.log(res);
        });
    },
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
      this.articleDetail();
      console.log(this.cancer)
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
          for (let gloclu of this.gloCluoptions) {
            this.gloclures.push(gloclu["GlobalCluster"]);
            this.Plot(this.cancer, gloclu["GlobalCluster"]);
          }
        });
    },
    Plot(cancer, gloclu) {
      var that = this;
      that.loading = true;
      this.$http
        .get("/tiger/singlecellimmu.php", {
          params: {
            cancer: cancer,
            gloclu: gloclu,
          },
        })
        .then(function (res) {
          if (res.data.status == 0) {
            Vue.set(that.plotsres, gloclu, res.data.output[0].split(","))
            Vue.set(that.cellnum, gloclu, res.data.cellnum[0].replace(/,/g," "))
            that.loading = false;
          }
        })
        .catch(function (res) {
          console.log(res);
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


