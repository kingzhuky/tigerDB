<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor">
        <el-card class="box-card-return">
          <div class="text item">
            <h1 style="font-weight: bold;font-size:25px;text-align:center">{{ gene }} -- {{cancer}}</h1>
          </div>
        </el-card>
      </div>

      <div class="infor">
        <el-card>
          <el-col :span="7">
            <el-row>
              <el-col :span="12">
                <p class="Responder">Responder Group</p>
                <el-select
                  v-model="responder"
                  multiple
                  placeholder="Choose at least one"
                  style="width:100%"
                >
                  <el-option
                    v-for="item in responseGroupOption"
                    :key="item.value"
                    :label="item.label"
                    :value="item.value"
                  ></el-option>
                </el-select>
              </el-col>

              <el-col :span="11" :offset="1">
                <p class="Responder">Non-Responder</p>
                <el-select
                  v-model="noresponder"
                  multiple
                  placeholder="Choose at least one"
                  style="width:100%"
                >
                  <el-option
                    v-for="item in noresponseGroupOption"
                    :key="item.value"
                    :label="item.label"
                    :value="item.value"
                  ></el-option>
                </el-select>
              </el-col>
            </el-row>
            <br />
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
              <el-radio v-model="logScale" label="TRUE">Yes</el-radio>
              <el-radio v-model="logScale" label="FALSE">No</el-radio>
            </el-row>
            <br />
            <el-row class="plot">
              <el-button id="anabt" @click="clickPlot()" style="width:100%">Plot</el-button>
            </el-row>
          </el-col>
          <el-col :span="8" :offset="1" v-show="resultShow">
            <div class="detailimg" v-loading="loading">
              <img width="450px" :src="imgUrlBox" />
            </div>
          </el-col>
          <el-col :span="7" :offset="1" v-show="resultShow">
            <div class="detailimg">
              <el-table
                ref="singleTable"
                border
                max-height="540"
                :data="tableData"
                v-loading="loading"
                :row-style="tableCellStyle"
                style="100%"
              >
                <el-table-column prop="signature_id" label="Signature Id" ></el-table-column>
                <el-table-column prop="Signature_Cite" label="Signature Cite" ></el-table-column>
                <el-table-column prop="AUC" label="AUC"></el-table-column>

              </el-table>
            </div>
          </el-col>

          <el-col  :span="14" v-show="!resultShow" v-loading="loading">
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
import {
  gStyle
} from "../../../../static/js/utils.js";

export default {
  props: {
    gene: '',
    cancer: '',
    datatype: ''
  },

  data() {
    return {
      tableLoading: "",
      resultShow:true,
      normalMed: "None",
      normalGene: "",
      logScale: "FALSE",
      responder: ["CR", "PR"],
      noresponder: ["PD", "SD"],
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
      imgpathBox: "",
      imgpathBar: "",
      loading: true,
      tableData:[],
    };
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
      this.getPlot(this.gene, this.cancer);
    },

    Plot(gene, mergedatasets) {
      this.responder = ["CR", "PR"];
      this.noresponder = ["PD", "SD"];
      this.normalMed = "None";
      this.logScale = "FALSE";
      this.getPlot(gene, mergedatasets);
    },

    gettableData(jsonUrl) {
      var that = this;
      this.$http
        .get("/tiger/img/" + jsonUrl + ".json")
        .then(function(res) {
          that.tableData = res.data;
        })
        .catch(function(res) {
          console.log(res);
        });
    },

        //渲染每个格子的颜色
    tableCellStyle({ row}) {
      console.log(row["AUC"])
      var mycolr = gStyle(parseFloat(row["AUC"]===undefined?"":row["AUC"]), 2.25);
      return {
        background: mycolr["background"],
        color: mycolr["color"]
      };
    },
     getSampleDetail(sample){
      this.$refs.sampleDetail.getTableData(sample)
    },
    getPlot(gene, mergedatasets) {
      if (this.checkInput()) {
        var that = this;
        that.loading = true;
        that.resultShow=true
        this.$http
          .get("/tiger/1.1.responseDiff.php", {
            params: {
              gene: gene,
              mergedatasets: mergedatasets,
              responder: this.responder.join(","),
              noresponder: this.noresponder.join(","),
              normalMed: this.normalMed,
              normalGene: this.normalMed == "None" ? "None" : this.normalGene,
              logScale: this.logScale,
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
</style>


