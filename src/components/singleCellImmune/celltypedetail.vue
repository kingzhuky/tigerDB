<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor">
        <el-card class="box-card-return">
          <div class="text item">
            <h1
              style="font-weight: bold;font-size:25px;text-align:center"
            >{{cancer}} -- {{ celltype }} -- {{gloclu}} -- {{gene}}</h1>
          </div>
        </el-card>
      </div>

      <div class="infor">
        <el-card>
          <el-row  v-loading="evoluloading">
            <el-row v-show="evolushow"  class="detailimg">
              <p class="card-title">tSNE</p>
              <el-col :span="11" v-show="evolushow2">
                <img id="singleimg" :src="'tiger/img/'+overviewimg.split(',')[0]+'.png'" />
              </el-col>
              <el-col :span="11" :offset="2">
                <img id="singleimg" :src="'tiger/img/'+evoluplots.split(',')[1]" />
              </el-col>
            </el-row>
            <el-row class="detailimg">
              <p class="card-title">Gene Expression</p>
              <el-col :span="20" :offset="2">
                <img id="singleimg" :src="'tiger/img/'+evoluplots.split(',')[0]" />
              </el-col>
            </el-row>
            <el-col :span="20" :offset="2" v-show="!evolushow" v-loading="loading">
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
    gene: {
      type: String,
    },
    cancer: {
      type: String,
    },
    celltype: { type: String },
    tabname: {
      type: String,
    },
  },

  data() {
    return {
      evolushow2: true,
      evolushow: true,
      tableLoading: "",
      normalMed: "None",
      normalGene: "",
      logScale: "FALSE",
      responder: ["CR", "PR"],
      noresponder: ["PD", "SD"],
      overviewimg: "",
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
      //geneplots: "",
      evoluplots: "",
      gloclu: "",
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
    // clickPlot() {
    //   //this.genePlot(this.gene);
    //   this.evoluPlot(this.gene);
    // },

    // genePlot(gene) {
    //   if (this.checkInput()) {
    //     var that = this;
    //     that.geneloading = true;
    //     that.geneshow = true;
    //     this.$http
    //       .get("/tiger/scimmudiffexpdetailgene.php", {
    //         params: {
    //           cancer: this.cancer,
    //           gene: gene,
    //           gloclu: this.gloclu,
    //           subclu: this.subClu.join(","),
    //         },
    //       })
    //       .then(function (res) {
    //         if (res.data.status == 0) {
    //           if (res.data.output[0] === "0") {
    //             that.geneshow = false;
    //           } else {
    //             that.geneshow = true;
    //             setTimeout((that.geneplots = res.data.output[0]), 1000);
    //           }
    //           //that.geneplots = res.data.output[0];
    //           that.geneloading = false;
    //         }
    //       })
    //       .catch(function (res) {
    //         console.log(res);
    //       });
    //   }
    // },
    //scimmudiffexpdetailevlou.php
    evoluPlot(gene, celltype) {
      if (this.checkInput()) {
        var that = this;
        that.evoluloading = true;
        this.$http
          .get("/tiger/scimmudiffexpdetailgene.php", {
            params: {
              cancer: this.cancer,
              celltype: celltype,
              type: this.tabname,
              gene: gene,
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              if (res.data.output[0] === "0") {
                that.evolushow = false;
                //alert("no gene file");
              } else {
                that.evolushow = true;
                that.evoluplots = res.data.output[0]
                that.gloclu = res.data.gloclu;
              }
              //that.evoluplots = res.data.output[0];
              that.evoluloading = false;
            }
            if (res.data.status2 == 0) {
              if (res.data.output2[0] === "0") {
                that.evolushow2 = false;
                //alert("no gene file");
              } else {
                that.evolushow2 = true;
                setTimeout((that.overviewimg = res.data.output2[0]), 1000);
              }
              //that.evoluplots = res.data.output[0];
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


