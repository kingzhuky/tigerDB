<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor" v-loading="loading" >
        <el-card v-for="gloclu in gloclures" :key="gloclu" class="overiewcard">
          <p class="card-title">{{gloclu}}</p>
          <el-row class="detailimg">
            <el-col :span="20" :offset="2">
              <p class="card-title">tSNE</p>
                <img id="singleimg" :src="'tiger/img/'+plotsres[gloclu][0]+'.png'" />
                <el-divider></el-divider>
                <p class="card-title">Differential cell fraction </p>
                <img id="singleimg" :src="'tiger/img/'+plotsres[gloclu][1]+'.png'" />
                <el-divider></el-divider>
                <img id="singleimg" :src="'tiger/img/'+plotsres[gloclu][2]+'.png'" />
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
    scimmuShow: false,
    scimmuresShow: false,
    gloclu: String,
    cancer: String,
    gloCluoptions: Array
    //subClu: Array,
  },

  data() {
    return {
      loading: true,
      crossloading: false,
      //plots: [],
      //crossplots: "",
      seargene: "HLA-A_CD3G",
      restaurants: [],
      crossClucoptions: [],
      crossClu: [],
      gloclures:[],
      plotsres:{}
      //subClucoptions: [],
      //subClu: [],
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

    // getcrossClu(cancer) {
    //   this.$http
    //     .get("/tiger/" + cancer + "/" + cancer + "/crosstalk.class.txt")
    //     .then((res) => {
    //       this.crossClucoptions = res.data.replace(/"/g, "").split("\n");
    //       //this.crossClu=this.crossClucoptions[0,4]
    //     });
    // },

    // selectchange() {
    //   this.$http
    //     .get("/tiger/genesug.php", {
    //       params: {
    //         gene: this.seargene,
    //         type: "ligandreceptor",
    //       },
    //     })
    //     .then((res) => {
    //       this.restaurants = res.data.list;
    //     });
    // },
    reset(){
      this.gloclures=[],
      this.plotsres={}
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

    // searchCro() {
    //   if (!this.checkdataset()) {
    //     this.scimmuresShow = true;
    //     this.scimmuShow = true;
    //     this.crossloading = true;
    //     var that = this;

    //     this.$http
    //       .get("/tiger/singlecellcross.php", {
    //         params: {
    //           cancer: this.cancer,
    //           subclu: this.crossClu.join(","),
    //           ligand: this.seargene.trim().split("_", 2)[0],
    //           recepto: this.seargene.trim().split("_", 2)[1],
    //         },
    //       })
    //       .then(function (res) {
    //         if (res.data.status == 0) {
    //           setTimeout((that.crossplots = res.data.output[0]), 1000);
    //           //that.crossplots = res.data.output[0];
    //           that.crossloading = false;
    //         } else {
    //           that.scimmuresShow = false;
    //         }
    //       })
    //       .catch(function (res) {
    //         console.log(res);
    //       });
    //   } else {
    //     alert("Please  select cross Clusters");
    //   }
    // },

    clickPlot() {
      this.reset()
      //let subClu2 = this.subClu.join(",");
      for (let gloclu of  this.gloCluoptions){
        console.log(this.gloCluoptions)
        console.log(gloclu)
        this.Plot(this.cancer, gloclu["glo"]);
      }
    },

    Plot(cancer, gloclu) {
      var that = this;
      that.loading = true;
      this.$http
        .get("/tiger/singlecellimmu.php", {
          params: {
            cancer: cancer,
            gloclu: gloclu
            //subclu: subclu,
          },
        })
        .then(function (res) {
          if (res.data.status == 0) {
            that.gloclures.push(gloclu)
            that.plotsres[gloclu]=res.data.output[0].split(',')
            // if (that.plots===[]){
            //   that.plots=res.data.output[0].split(',')
            // }else{
            //     that.plots.push(...res.data.output[0].split(','))
            // }
            that.loading = false;
          }
        })
        .catch(function (res) {
          console.log(res);
        });
    },
  },

  components: {
    "v-goTop": goTop,
  },
};
</script>

<style>
/* img#singleimg {
  width: 600px;
} */
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


