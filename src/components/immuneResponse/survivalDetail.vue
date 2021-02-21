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

      <el-card class="infor"> 
          <el-col :span="6">
            <el-row class="detail1">Normalized By</el-row>
            <br />
            <el-row class="detail2">
              <el-radio v-model="normalMed" label="None">None</el-radio>
              <el-radio v-model="normalMed" label="gene">Gene</el-radio>
            </el-row>
            <br />
            <el-row>
              <el-input v-model="normalGene" v-show='normalMed!="None"' placeholder="Please Input Gene Symbol"></el-input>
            </el-row>
            <br />

            <el-row class="detail1">Group Cutoff</el-row>

            <el-row>
              <el-slider v-model="expcutoff" :min="0.1" :max="0.5" :step="0.1"></el-slider>
            </el-row>
            <el-row>
              <el-col :span="12">
                <p>Low Expression</p>
                <el-input v-model="expcutoff" placeholder="0 ~ 0.5"></el-input>
              </el-col>
              <el-col :span="11" :offset="1">
                <p>high Expression</p>
                <el-input v-model="expcutoff2" placeholder="0.5 ~ 1"></el-input>
              </el-col>
            </el-row>
            <br />

            <el-row class="plot">
              <el-button id="anabt" @click="surClickPlot" style="width:100%">Plot</el-button>
            </el-row>
            <br />
          </el-col>
          <el-col :span="7" :offset="1" v-show="resultShow">
            <div class="detailimg" v-loading="loading">
              <p class="imgtitle">Survival Analysis</p>
              <img id="surplot" :src="imgUrlBox" />
            </div>
          </el-col>
          <el-col :span="9" :push="1" v-show="resultShow">
            <div class="detailimg">
              <el-table
                ref="singleTable"
                border
                max-height="420"
                :data="tableData"
                v-loading="loading"
                :row-style="tableCellStyle"
                header-row-class-name="tableHead"
                @row-click="openDetails"
                style="100%"
              >
                <el-table-column prop="signature_id" label="ID" width="90%" ></el-table-column>
                <el-table-column prop="Signature_Cite" label="Description" width="130%" ></el-table-column>
                <el-table-column prop="HR" label="HR" width="80%" sortable></el-table-column>
                <el-table-column prop="CI95" label="95% CI" width="90%" sortable></el-table-column>
                <el-table-column prop="PValue" label="P Value" width="90%" sortable></el-table-column>
              </el-table>
            </div>
          </el-col>
          <el-col  :span="14" v-show="!resultShow" v-loading="loading">
            <div id="norult">No result</div>
          </el-col>
        </el-card>
        
        <v-sampleDetail ref="sampleDetail"></v-sampleDetail>
      

      <v-goTop></v-goTop>
    </div>
  </transition>
</template>

<script>
import goTop from "../public/goTop";
import sampleDetail from "./sampledetail";
import {
  gStyle
} from "../../../static/js/utils.js";
//import { downloadFile } from "../../../static/js/utils.js";

export default {
  props: {
    gene: String,
    cancer: String,
    datatype: String
  },

  data() {
    return {
      expcutoff: 0.50,
      resultShow:true,
      expcutoff2: 0.5,
      normalMed: "None",
      normalGene: "",
      responder: ["CR", "PR"],
      noresponder: ["PD", "SD"],
      tableDataheader: ["sig", "pvalue"],
      responseGroupOption: [
        {
          value: "CR",
          label: "CR"
        },
        {
          value: "PR",
          label: "PR"
        }
      ],
      noresponseGroupOption: [
        {
          value: "PD",
          label: "PD"
        },
        {
          value: "SD",
          label: "SD"
        }
      ],
      imgpath: "",
      imgpathBox: "",
      imgpathBar: "",
      loading: true,
      tableData: [],
    };
  },

  watch: {
    expcutoff() {
      this.expcutoff2 = (1 - this.expcutoff).toFixed(2);
    },
    expcutoff2() {
      this.expcutoff = (1 - this.expcutoff2).toFixed(2);
    }
  },

  methods: {
    getSampleDetail(sample){
      this.$refs.sampleDetail.getTableData(sample)
    },
    getGeneDetail(gene){
      this.$refs.sampleDetail.getGeneData(gene)
    },
    gettableData(jsonUrl) {
      var that = this;
      this.$http
        .get("/tiger/img/" + jsonUrl + ".json")
        .then(function(res) {
          that.tableData = res.data;
        })
        .catch(function(res) {
          // console.log(res);
        });
    },
    tableCellStyle({row}) {
      var mycolr = ""
      if(parseFloat(row["PValue"]) < 0.1){
        mycolr = "#f0b6b6"
      }else{
        mycolr = "rgb(255,255,255)"
      }
      return {
        background: mycolr
      };
    },
    openDetails(row){
      // console.log(row.signature_id);
      this.$router.push({
        name: "immuneSignature",
        params: {
          sigid: row.signature_id,
        },
      });
    },
    checkInput() {
      // if (this.normalMed!=='None' && this.normalGene.length==0){
      //   alert("please input Normalized gene or Cell fration")
      //   return false;
      // }
      return true;
    },
    surClickPlot() {
      this.Plot(this.gene, this.cancer);
    },
    surPlot(gene, mergedatasets) {
      (this.expcutoff = 0.5),
        (this.expcutoff2 = ""),
        (this.normalMed = "None"),
        (this.normalGene = ""),
        (this.responder = ["CR", "PR"]),
        (this.noresponder = ["PD", "SD"]),
        this.Plot(gene, mergedatasets);
    },
    Plot(gene, mergedatasets) {
      
      if (this.checkInput()) {
        var that = this;
        that.loading = true;
        that.resultShow=true
        this.$http
          .get("/tiger/1.3.responseSur.php", {
            params: {
              gene: gene,
              mergedatasets: mergedatasets,
              expcutoff: this.expcutoff,
              normalMed: this.normalMed,
              normalGene: this.normalMed == "None" ? "None" : this.normalGene,
              datatype: "png"
            }
          })
          .then(function(res) {
            if (res.data.status == 0) {
              
              let imgpath = res.data.output[0].split(",");
              setTimeout(that.imgpathBox = imgpath[0],1000);
              that.gettableData(imgpath[1]);
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
    },
    imgUrlBar: function() {
      return "tiger/img/" + this.imgpathBar + ".png";
    }
  },

  components: {
    "v-goTop": goTop,
    "v-sampleDetail":sampleDetail
  }
};
</script>

<style>
img#surplot {
    width: 400px;
}
.el-table--enable-row-hover .el-table__body tr:hover{
  cursor: pointer;
}
</style>


