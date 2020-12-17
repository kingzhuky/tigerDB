<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor">
        <el-card class="box-card-return">
          <div class="text item">
            <h1 style="font-weight: bold;font-size:25px;text-align:center">{{cancer}}<br>Gene:{{gene}}</h1>
          </div>
        </el-card>
      </div>
      <div class="infor">
        <el-card>
          <el-col :span="8" :offset="1">
            <el-row class="detail1">Normalized By</el-row>
            <br />
            <el-row class="detail2">
              <el-radio v-model="normalMed" label="None">None</el-radio>
              <el-radio v-model="normalMed" label="gene">Gene</el-radio>
            </el-row>
            <br />
            <el-row>
              <el-input v-model="normalGene"></el-input>
             </el-row>
            <br />
            <el-row class="detail1">Log Scale</el-row>
            <br />
            <el-row>
              <el-radio v-model="logScale" label="FALSE">No</el-radio>
            </el-row>
            <br />
            <el-row class="plot">
              <el-button id="anabt" @click="clickPlot()" style="width:100%">Plot</el-button>
            </el-row>
          </el-col>
          <el-col v-show="resultShow" :span="10" :offset="4" v-loading="loading">
            <img style="position:relative;top:0px;right:0px;" width="420px" :src="imgUrlBox" />
          </el-col>
          <el-col  :span="15" v-show="!resultShow" v-loading="loading">
            <div id="norult">No result</div>
          </el-col>
        </el-card>
       <v-sampleDetail ref="sampleDetail"></v-sampleDetail>
      </div>
      <v-goTop></v-goTop>
    </div>
  </transition>
</template>

<script>
import goTop from "../../public/goTop";
import sampleDetail from "../sampledetail";

//import { downloadFile } from "../../../static/js/utils.js";

export default {
  props: {
   gene: String,
    cancer: String,
    datatype: String
  },

  data() {
    return {
      resultShow:true,
      normalMed: "None",
      normalGene: "",
      logScale: "FALSE",
      loading: true,
      imgpathBox: "",
    };
  },

  methods: {
      getSampleDetail(sample){
      this.$refs.sampleDetail.getTableData(sample)
    },
    checkInput() {
      if (this.normalMed !== "None" && this.normalGene.length == 0) {
        alert("please input Normalized gene or Cell fration");
        return false;
      }
      return true;
    },

    clickPlot() {
      this.getPlot(this.gene, this.cancer);
    },

    Plot(gene, mergedatasets) {
      this.normalMed = "None";
      this.logScale = "FALSE";
      this.getPlot(gene, mergedatasets);
    },

        //渲染每个格子的颜色
    tableCellStyle({ row, column}) {
      var mycolr = gStyle(parseFloat(row[column["label"]]), 2.25);
      return {
        background: mycolr["background"],
        color: mycolr["color"]
      };
    },

    
    getPlot(gene, mergedatasets) {
      if (this.checkInput()) {
        var that = this;
        that.loading = true;
        that.resultShow=true
        this.$http
          .get("/tiger/1.2.responseDiffTherapy.php", {
            params: {
              gene: gene,
              mergedatasets: mergedatasets,
              normalMed: this.normalMed,
              normalGene: this.normalMed == "None" ? "None" : this.normalGene,
              logScale: this.logScale,
              datatype: "png"
            }
          })
          .then(function(res) {
            if (res.data.status == 0) {
              that.resultShow=true
              setTimeout(that.imgpathBox =res.data.output[0],1000);
              
              that.loading = false;
            }else{
              that.resultShow=false
            }
          })
          .catch(function(res) {
            console.log(res);
          });
      }
    }
  },

  computed: {
    imgUrlBox: function() {
      return "tiger/img/" + this.imgpathBox + ".png";
    }
  },

  components: {
    "v-goTop": goTop,
     "v-sampleDetail":sampleDetail
  }
};
</script>

<style>

</style>


