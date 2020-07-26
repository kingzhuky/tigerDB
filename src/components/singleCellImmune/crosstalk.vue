<template>
  <transition name="move3">
    <div >
   
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
                <el-select v-model="crossClu" multiple placeholder="Select Cluster" v-loading="crossCluloading">
                  <el-option
                    v-for="item in crossClucoptions"
                    :key="item"
                    :label="item"
                    :value="item"
                  ></el-option>
                </el-select>
              </el-col>
              <el-col :span="6" id="homeInput">
                <el-autocomplete
                  v-model="seargene"
                  :fetch-suggestions="querySearchAsync"
                  placeholder="Search Ligand or Receptor"
                  @input="selectchange"
                ></el-autocomplete>
              </el-col>
              <el-col :span="6" :offset="2">
                <el-button id="scimmubt" @click="searchCro">Search</el-button>
              </el-col>
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
          <div v-show="!scimmuresShow" id="norult">No result</div>
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
    subClu: {
      type: Array,
    },
    gloclu: {
      type: String,
    },
    subClucoptions: Array,
    clickGene: {
      type: String,
    },
  },

  data() {
    return {
      crossCluloading:true,
      crossloading: false,
      plots: "",
      crossplots: "",
      seargene: "HLA-A_CD3G",
      restaurants: [],
      crossClucoptions: [],
      crossClu: [],
      seargene: "HLA-A_CD3G",
      //evoluplots: "",
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
      this.crossCluloading=true
      this.$http
        .get("/tiger/" + cancer + "/" + cancer + "/crosstalk.class.txt")
        .then((res) => {
          console.log(res.data.replace(/"/g, "").split("\n"))
          this.crossClucoptions = res.data.replace(/"/g, "").split("\n");
          this.crossClu=this.crossClucoptions
          this.crossCluloading=false
        });
    },

    selectchange() {
      this.$http
        .get("/tiger/genesug.php", {
          params: {
            gene: this.seargene,
            type: "ligandreceptor",
          },
        })
        .then((res) => {
          this.restaurants = res.data.list;
        });
    },


     checkdataset() {
      console.log(Array.isArray(this.crossClu) && this.crossClu.length === 0);
      console.log(this.seargene === "");
      if (
        (Array.isArray(this.crossClu) && this.crossClu.length === 0) ||
        this.seargene.trim() === ""
      ) {
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
              recepto: this.seargene.trim().split("_", 2)[1],
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              setTimeout((that.crossplots = res.data.output[0]), 1000);
              //that.crossplots = res.data.output[0];
            } else {
              that.scimmuresShow = false;
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


