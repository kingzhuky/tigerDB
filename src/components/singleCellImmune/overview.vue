<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor">
        <el-card>
          <p class="card-title">Overview</p>
          <el-row
            v-loading="loading"
            v-for="item in plots.split(',')"
            :key="item"
            class="detailimg"
          >
            <img id="singleimg" :src="'tiger/img/'+item+'.png'" />
            <el-divider></el-divider>
          </el-row>
        </el-card>
        <el-card id="scummuviewer">
          <p class="card-title">Cross Talk</p>
          <el-row>
            <el-col :span="6" :offset="2">
              <el-row>
                <span id="homespan">Select Clusters</span>
              </el-row>
            </el-col>
            <el-col :span="5" :offset="2">
              <el-row>
                <span id="homespan">Search Ligand or Receptor</span>
              </el-row>
            </el-col>
          </el-row>
          <br />
          <el-row>
            <el-col :span="20" :offset="2">
              <el-col :span="10" :offset="0">
                <el-select v-model="crossClu" multiple placeholder="Select Cluster">
                  <el-option
                    v-for="item in crossClucoptions"
                    :key="item"
                    :label="item"
                    :value="item"
                  ></el-option>
                </el-select>
              </el-col>
              <el-col :span="8" id="homeInput">
                <el-autocomplete
                  v-model="seargene"
                  :fetch-suggestions="querySearchAsync"
                  placeholder="Search Ligand or Receptor"
                  @input="selectchange"
                ></el-autocomplete>
              </el-col>
              <el-col :span="6">
                <el-button id="scimmubt" @click="searchCro">Search</el-button>
              </el-col>
            </el-col>
          </el-row>

          <div id="crossplot" v-loading="crossloading" v-show="scimmuShow">
            <el-row v-for="item2 in crossplots.split(',')" :key="item2" class="detailimg">
              <img id="singleimg" :src="'tiger/img/'+item2+'.png'" />
              <el-divider></el-divider>
            </el-row>
            <div v-show="!scimmuresShow" id="norult">No result</div>
          </div>
        </el-card>
      </div>

      <v-goTop></v-goTop>
    </div>
  </transition>
</template>

<script>
import goTop from "../public/goTop";

//import { downloadFile } from "../../../static/js/utils.js";

export default {
  props: {
    scimmuShow: false,
    scimmuresShow: false,
    gloclu: String,
    cancer: String,
    subclu: Array
  },

  data() {
    return {
      loading: true,
      crossloading: false,
      plots: "",
      crossplots: "",
      seargene: "HLA-A_CD3G",
      restaurants: [],
      crossClucoptions: [],
      crossClu: []
    };
  },

  mounted() {
    this.Plot(this.cancer, this.gloclu, this.subclu.join(","));
    this.getcrossClu(this.cancer);
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
      return restaurant => {
        return (
          restaurant.value.toLowerCase().indexOf(queryString.toLowerCase()) ===
          0
        );
      };
    },

    getcrossClu(cancer) {
      this.$http
        .get("/tiger/" + cancer + "/" + cancer + "/crosstalk.class.txt")
        .then(res => {
          this.crossClucoptions = res.data.replace(/"/g, "").split("\n");
          //this.crossClu=this.crossClucoptions[0,4]
        });
    },

    selectchange() {
      this.$http
        .get("/tiger/genesug.php", {
          params: {
            gene: this.seargene,
            type: "ligandreceptor"
          }
        })
        .then(res => {
          this.restaurants = res.data.list;
        });
    },

    checkdataset() {
      console.log(Array.isArray(this.crossClu) && this.crossClu.length === 0)
      console.log(this.seargene==="" )
      if (Array.isArray(this.crossClu) && this.crossClu.length === 0 || this.seargene.trim()==="" ) {
        return true;
      }
      return false;
    },

    searchCro() {
      if (!this.checkdataset()) {
        this.scimmuresShow = true;
        this.scimmuShow = true;
        this.crossloading = true;
        var that = this;

        this.$http
          .get("/tiger/singlecellcross.php", {
            params: {
              cancer: this.cancer,
              subclu: this.crossClu.join(","),
              ligand: this.seargene.trim().split("_", 2)[0],
              recepto: this.seargene.trim().split("_", 2)[1]
            }
          })
          .then(function(res) {
            if (res.data.status == 0) {
              setTimeout((that.crossplots = res.data.output[0]), 1000);
              //that.crossplots = res.data.output[0];
              that.crossloading = false;
            } else {
              that.scimmuresShow = false;
            }
          })
          .catch(function(res) {
            console.log(res);
          });
      }else{
        alert("Please  select cross Clusters")
      }
    },

    Plot(cancer, gloclu, subclu) {
      var that = this;
      that.loading = true;
      this.$http
        .get("/tiger/singlecellimmu.php", {
          params: {
            cancer: cancer,
            gloclu: gloclu,
            subclu: subclu
          }
        })
        .then(function(res) {
          if (res.data.status == 0) {
            setTimeout((that.plots = res.data.output[0]), 1000);
            that.loading = false;
          }
        })
        .catch(function(res) {
          console.log(res);
        });
    }
  },

  components: {
    "v-goTop": goTop
  }
};
</script>

<style>
img#singleimg {
  width: 700px;
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


