<template>
  <div>
    <el-row id="coExpInput">
      <br />
      <br />
      <el-col :span="8" :offset="6">
        <el-autocomplete
        v-model="searchinput"
        placeholder="Please Input Gene Symbol"
        :fetch-suggestions="querySearchAsyncA"
        @keyup.enter.native="searchClick"
      ></el-autocomplete>
      </el-col>
      <el-col :span="4">
        <el-button id="homebt" @click="searchClick" icon="el-icon-search"></el-button>
      </el-col>
    </el-row>
    <br />
        <div class="detail-card">
      <div class="infor" v-loading="evoluloading" >
        <el-card v-for="gloclu in gloclures" :key="gloclu" class="overiewcard">
          <p class="card-title">{{gloclu}}</p>
          <el-row class="detailimg">
            <el-col :span="20" :offset="2">
              <div v-for="item in plotsres[gloclu]" :key="item">
                <img id="singleimg" :src="'tiger/img/'+item" />
                <el-divider></el-divider>
              </div>
            </el-col>
          </el-row>
        </el-card>
        
      </div>

      <v-goTop></v-goTop>
    </div>
   
   
  </div>
</template>

<script>
import goTop from "../public/goTop";

export default {
  props: {
    cancer: String,
    gloCluoptions: Array
  },
  data() {
    return {
      tableShow: false,
      searchinput: "CXCL13",
      isShow:false,
      gloclures:[],
      plotsres:{}
    };
  },

  methods: {
    reset(){
      this.gloclures=[],
      this.plotsres={}
    },
    checkInput() {
      if (this.searchinput.trim() === "") {
        alert("please input gene");
        return false;
      }
      return true;
    },
    evoluPlot(cancer,gloclu,gene) {
      if (this.checkInput()) {
        var that = this;
        that.evoluloading = true;
        this.$http
          .get("/tiger/scimmudiffexpdetailgene.php", {
            params: {
              type: "evolution",
              cancer: cancer,
              gloclu:gloclu,
              gene: gene
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              if (res.data.output[0] === "0") {
                that.evolushow = false;
                //alert("no gene file");
              } else {
                that.evolushow = true;
                that.gloclures.push(gloclu)
                that.plotsres[gloclu]=res.data.output[0].split(',')
              }
              //that.evoluplots = res.data.output[0];
              that.evoluloading = false;
            }
          })
          .catch(function (res) {
            console.log(res);
          });
      }
    },
    querySearchAsyncA(queryString, cb) {
      this.$http
        .get("/m6a2target/genesug", {
          params: {
            gene: this.searchinput,
            species: "Human",
          },
        })
        .then((res) => {
          cb(res.data.datasetinfo);
        });
    },
    searchClick() {
      this.isShow=true
      for (let gloclu of  this.gloCluoptions){
        this.evoluPlot(this.cancer, gloclu["glo"],this.searchinput);
      }
    },
   
  }
};
</script>


<style>
.el-table__fixed {
  cursor: not-allowed;
}

#coExpInput .el-autocomplete {
    width: 100%;
}

#scCoExpTable th {
  left: 70px !important;
  height: 140px !important;
}
</style>
