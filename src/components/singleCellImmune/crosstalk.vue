<template>
  <transition name="move3">
    <div>
      <el-card id="scummuviewer">
        <p class="card-title">Cross Talk</p>
        <el-row>
          <el-col :span="6" :offset="1">
            <el-row>
              <span id="homespan">Select Cell</span>
            </el-row>
          </el-col>
          <el-col :span="6" >
            <el-row>
              <span id="homespan">Select Clusters</span>
            </el-row>
          </el-col>
          <el-col :span="4">
            <el-row>
              <span id="homespan">Search Ligand or Receptor</span>
            </el-row>
          </el-col>
        </el-row>
        <br />
        <el-row>
             <el-col :span="6" :offset="1">
              <el-select
                v-model="gloclu"
                placeholder="Select Cluster"
              >
                <el-option label="ALl Cells" value="ALl"></el-option>
                <el-option label="T cells" value="Tcells"></el-option>
                <el-option label="B cells" value="Bcells"></el-option>
              </el-select>
            </el-col>

            <el-col :span="6" :offset="0">
              <el-select
                v-model="crossClu"
                multiple
                placeholder="Select Cluster"
                v-loading="crossCluloading"
              >
                <el-option v-for="item in crossClucoptions" :key="item" :label="item" :value="item"></el-option>
              </el-select>
            </el-col>
            <el-col :span="6" id="homeInput">
              <el-autocomplete
                v-model="seargene"
                :fetch-suggestions="querySearchAsync"
                placeholder="Search Ligand or Receptor"
                :trigger-on-focus="false"
              ></el-autocomplete>
            </el-col>
            <el-col :span="4" >
              <el-button id="scimmubt" @click="searchCro">Search</el-button>
            </el-col>
        </el-row>

        <div id="crossplot" v-loading="crossloading" v-show="scimmuShow">
          <el-row class="detailimg">
            <img id="singleimg" :src="'tiger/img/'+crossplots.split(',')[0]+'.png'" />
            <el-divider></el-divider>
          </el-row>

          <el-row class="detailimg" v-if="crossplots.split(',').length>1">
            <el-col :span="12">
              <img id="singleimg" :src="'tiger/img/'+crossplots.split(',')[1]+'.png'" />
            </el-col>
            <el-col :span="12">
              <img id="singleimg" :src="'tiger/img/'+crossplots.split(',')[2]+'.png'" />
            </el-col>
          </el-row>
        </div>
        <div v-show="scimmuShowNoRes" id="norult">No result</div>
      </el-card>
      <v-goTop></v-goTop>
    </div>
  </transition>
</template>

<script>
import goTop from "../public/goTop";

export default {
  props: {
    gene: {
      type: String,
    },
    cancer: {
      type: String,
    },
    // subClu: {
    //   type: Array,
    // },
    //subClucoptions: Array,
    clickGene: {
      type: String,
    },
  },

  data() {
    return {
      gloclu:"All",
      crossCluloading: true,
      crossloading: false,
      plots: "",
      crossplots: "",
      seargene: "HLA-A_CD3G",
      restaurants: [],
      crossClucoptions: [],
      crossClu: [],
      seargene: "HLA-A_CD3G",
      scimmuShowNoRes: false,
    };
  },

  mounted() {
    this.getcrossClu(this.cancer);
  },

  methods: {
    checkInput() {
      if (this.normalMed !== "None" && this.normalGene.length == 0) {
        alert("please input Normalized gene or Cell fration");
        return false;
      }
      return true;
    },
    clickPlot() {
      this.genePlot(this.clickGene);
      //this.evoluPlot(this.clickGene);
    },

    getcrossClu(cancer) {
      this.crossCluloading = true;
      this.$http
        .get("/tiger/" + cancer + "/" + cancer + "/crosstalk.class.txt")
        .then((res) => {
          this.crossClucoptions = res.data.replace(/"/g, "").split("\n");
          this.crossClu = [this.crossClucoptions[0]];
          this.crossCluloading = false;
        });
    },
    createStateFilter(queryString) {
      return (restaurant) => {
        return (
          restaurant.value.toLowerCase().indexOf(queryString.toLowerCase()) ===
          0
        );
      };
    },
    querySearchAsync(queryString, cb) {
      // var restaurants = this.restaurants;
      // var results = queryString
      //   ? restaurants.filter(this.createStateFilter(queryString))
      //   : restaurants;
      // console.log(results)
      this.$http
        .get("/tiger/genesug.php", {
          params: {
            gene: this.seargene,
            type: "ligandreceptor",
          },
        })
        .then((res) => {
          cb(res.data.list);
        });
      
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

    reset() {
      this.scimmuShow = false;
      this.scimmuShowNoRes = false;
    },

    searchCro() {
      if (!this.checkdataset()) {
        this.scimmuShow = true;
        this.scimmuShowNoRes = false;
        this.crossloading = true;
        var that = this;

        this.$http
          .get("/tiger/singlecellcross.php", {
            params: {
              cancer: this.cancer,
              gloclu: this.gloclu,
              subclu: this.crossClu.join(","),
              ligand: this.seargene.trim().split("_", 2)[0],
              recepto: this.seargene.trim().split("_", 2)[1],
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              setTimeout((that.crossplots = res.data.output[0]), 1000);
              //that.crossplots = res.data.output[0];
            } else {
              that.scimmuShow = false;
              that.scimmuShowNoRes = true;
            }
            that.crossloading = false;
          })
          .catch(function (res) {
            console.log(res);
          });
      } else {
        alert("Please  select cross Clusters");
      }
    },
  },

  components: {
    "v-goTop": goTop,
  },
};
</script>

<style>
</style>


