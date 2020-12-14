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
            <el-row class="detailimg">
              <p class="card-title">Differential Expression</p>
              <el-col :span="20" :offset="2">
                <img id="singleimg" :src="'tiger/img/'+geneplots.split(',')[0]" />
              </el-col>
            </el-row>
            <el-row></el-row>
              <el-row v-show="geneshow" class="detailimg">
              <p class="card-title">tSNE</p>
                <el-col :span="11" v-show="geneshow2">
                  <img id="singleimg" :src="'tiger/img/'+overviewimg.split(',')[0]+'.png'" />
                </el-col>
                <el-col :span="11" :offset="2">
                  <img id="singleimg" :src="'tiger/img/'+geneplots.split(',')[1]" />
                </el-col>
              </el-row>
              <el-col :span="16" :offset="2" v-show="!geneshow" v-loading="loading">
                <div id="norult">No result</div>
              </el-col>
            </el-row>
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
    gene: {
      type: String,
    },
    cancer: {
      type: String,
    },
    celltype: { type: String },
    gloclu: { 
      type: String 
    },
    clickGene: {
      type: String,
    },
  },

  data() {
    return {
      overviewimg: "",
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
      geneplots: "",
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
      this.genePlot(this.clickGene);
      //this.evoluPlot(this.clickGene);
    },

    genePlot(clickgene, celltype, gloclu) {
      if (this.checkInput()) {
        var that = this;
        that.geneloading = true;
        that.geneshow = true;
        this.$http
          .get("/tiger/scimmudiffexpdetailgene.php", {
            params: {
              cancer: this.cancer,
              gene: clickgene,
              type: "exp",
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
                that.geneplots = res.data.output[0];
              }
              //that.geneplots = res.data.output[0];
              that.geneloading = false;
            }
            if (res.data.status2 == 0) {
              if (res.data.output2[0] === "0") {
                that.geneshow2 = false;
              } else {
                that.geneshow2 = true;
                // setTimeout((that.overviewimg = res.data.output2[0]), 1000);
                that.overviewimg = res.data.output2[0]
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


