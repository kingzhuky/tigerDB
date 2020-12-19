<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor">
        <el-card class="box-card-return">
          <div class="text item">
            <h1
              style="font-weight: bold;font-size:25px;text-align:center"
            >Cancer Type: {{cancer}}<br>Global Cluster:{{gloclu}}</h1>
          </div>
        </el-card>
      </div>

      <div class="infor">
        <el-card>
          <el-row v-loading="geneloading">
            <el-row class="detailimg" v-show="geneshow">
              <el-col :span="6" v-show="evolushow2">
                <p class="imgtitle">Cell Types</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="250px"
                  :src="'tiger/img/' + pathwayplots.split(',')[0] + '.png'"
                  @click="previewImg(['tiger/img/' + pathwayplots.split(',')[0] + '.png','tiger/img/' + pathwayplots.split(',')[1] + '.png','tiger/img/' + pathwayplots.split(',')[2] + '.png'])">
              </el-col>
              <el-col :span="6" v-show="evolushow2">
                <p class="imgtitle">UMAP Plot of {{gene}} Expression</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="250px"
                  :src="'tiger/img/' + pathwayplots.split(',')[1] + '.png'"
                  @click="previewImg(['tiger/img/' + pathwayplots.split(',')[0] + '.png','tiger/img/' + pathwayplots.split(',')[1] + '.png','tiger/img/' + pathwayplots.split(',')[2] + '.png'])">
              </el-col>
              <el-col :span="12" v-show="evolushow2">
                <p class="imgtitle">Boxplot of {{gene}} Expression</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="450px"
                  :src="'tiger/img/' + pathwayplots.split(',')[2] + '.png'"
                  @click="previewImg(['tiger/img/' + pathwayplots.split(',')[0] + '.png','tiger/img/' + pathwayplots.split(',')[1] + '.png','tiger/img/' + pathwayplots.split(',')[2] + '.png'])">
              </el-col>
            </el-row>
              <el-col :span="16" :offset="2" v-show="!geneshow" v-loading="loading">
                <div id="norult">No result</div>
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
    pathway: {
      type: String,
    },
    cancer: {
      type: String,
    },
    celltype: { 
      type: String 
    },
    gloclu: { 
      type: String 
    },
    tabtype: { 
      type: String 
    },
  },

  data() {
    return {
      // overviewimg: "",
      geneshow: true,
      geneshow2: true,
      tableLoading: "",
      normalMed: "None",
      normalGene: "",
      logScale: "FALSE",
      responder: ["CR", "PR"],
      noresponder: ["PD", "SD"],
      responseGroupOption: [
        {
          value: "CR",
          label: "CR",
        },
        {
          value: "PR",
          label: "PR",
        },
      ],
      noresponseGroupOption: [
        {
          value: "PD",
          label: "PD",
        },
        {
          value: "SD",
          label: "SD",
        },
      ],

      imgpathBox: "",
      imgpathBar: "",
      imgpath: "",
      imgpathEvo: "",
      evoluloading: true,
      geneloading: true,
      pathwayplots: "",
      evoluplots: "",
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
      this.pathwayPlot(this.pathway, this.celltype, this.gloclu, this.tabtype);
      //this.evoluPlot(this.clickGene);
    },

    pathwayPlot(clickname, celltype, gloclu, tabtype) {
      if (this.checkInput()) {
        var that = this;
        that.geneloading = true;
        that.geneshow = true;
        var plottype = "";
        if(that.tabtype === "cluster"){
          plottype = "pathway"
        }else{
          plottype = "pathwaydiff"
        }
        this.$http
          .get("/tiger/scimmudiffexpdetailgene.php", {
            params: {
              cancer: this.cancer,
              gene: clickname,
              type: plottype,
              celltype: celltype,
              gloclu: gloclu
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              if (res.data.output[0] === "0") {
                that.geneshow = false;
              } else {
                that.geneshow = true;
                that.pathwayplots = res.data.output[0];
              }
              that.geneloading = false;
            }
            if (res.data.status2 == 0) {
              if (res.data.output2[0] === "0") {
                that.geneshow2 = false;
              } else {
                that.geneshow2 = true;
                // setTimeout((that.overviewimg = res.data.output2[0]), 1000);
                // that.overviewimg = res.data.output2[0]
              }
            }
          })
          .catch(function (res) {
            console.log(res);
          });
      }
    },
  },

  computed: {
    imgUrlWgcna: function () {
      return "tiger/img/" + this.imgpath + ".png";
    },
    imgUrlBox: function () {
      return "tiger/img/" + this.imgpathBox + ".png";
    },
    imgUrlBar: function () {
      return "tiger/img/" + this.imgpathBar + ".png";
    },
    imgUrlEvo: function () {
      return "tiger/img/" + this.imgpathEvo + ".png";
    },
  },

  components: {
    "v-goTop": goTop,
  },
};
</script>

<style>
</style>


