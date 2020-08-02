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
          <el-row>
            <el-col :span="5" :offset="1" id="homeInput">
              
              <i class="el-icon-setting"></i>Optional
              <br />
              <br />
              <el-select v-model="subClu" multiple>
                <el-option v-for="item in subClucoptions" :key="item" :label="item" :value="item"></el-option>
              </el-select>
              <br />
              <br />
              <el-row class="plot">
                <el-button id="anabt" @click="clickPlot()" style="width:80%">Plot</el-button>
              </el-row>
            </el-col>
            <el-col :span="16" :offset="2" >
             

              <el-row
                v-show="evolushow"
                v-loading="evoluloading"
                v-for="item in evoluplots.split(',')"
                :key="item"
                class="detailimg"
              >
                <img id="singleimg" :src="'tiger/img/'+item" />
                <el-divider></el-divider>
              </el-row>
            </el-col>
            <el-col  :span="16" :offset="2" v-show="!evolushow" v-loading="loading">
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
      evolushow: true,
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
      //geneplots: "",
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
      //this.genePlot(this.clickGene);
      this.evoluPlot(this.clickGene);
    },

    // genePlot(clickgene) {
    //   if (this.checkInput()) {
    //     var that = this;
    //     that.geneloading = true;
    //     that.geneshow = true;
    //     this.$http
    //       .get("/tiger/scimmudiffexpdetailgene.php", {
    //         params: {
    //           cancer: this.cancer,
    //           gene: clickgene,
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

    evoluPlot(clickgene) {
      if (this.checkInput()) {
        var that = this;
        that.evoluloading = true;
        this.$http
          .get("/tiger/scimmudiffexpdetailevlou.php", {
            params: {
              cancer: this.cancer,
              gloclu: this.gloclu,
              subclu: this.subClu.join(","),
              gene: clickgene,
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              if (res.data.output[0] === "0") {
                that.evolushow = false;
                //alert("no gene file");
              } else {
                that.evolushow = true;
                setTimeout((that.evoluplots = res.data.output[0]), 1000);
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


