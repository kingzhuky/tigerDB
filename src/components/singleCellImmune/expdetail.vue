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
          <el-row
          v-show="geneshow"
            v-loading="geneloading"
            v-for="item in geneplots.split(',')"
            :key="item"
            class="detailimg"
          >
            <img id="singleimg" :src="'tiger/img/'+item" />
            <el-divider></el-divider>
          </el-row>

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
      type: String
    },
    cancer: {
      type: String
    },
    subclu: {
      type: Array
    },
    gloclu: {
      type: String
    }
  },

  data() {
    return {
      geneshow:true,
      evolushow:true,
      tableLoading: "",
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
      imgpath: "",
      imgpathEvo: "",
      evoluloading: true,
      geneloading: true,
      geneplots: "",
      evoluplots: ""
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


    genePlot(clickgene) {
      if (this.checkInput()) {
        var that = this;
        that.geneloading = true;
         that.geneshow=true
        this.$http
          .get("/tiger/scimmudiffexpdetailgene.php", {
            params: {
              cancer: this.cancer,
              gene: clickgene,
              gloclu: this.gloclu,
              subclu: this.subclu.join(",")
            }
          })
          .then(function(res) {
            if (res.data.status == 0) {
              if (res.data.output[0] === "0") {
               
                that.geneshow=false
              } else {
                that.geneshow=true
                setTimeout((that.geneplots = res.data.output[0]), 1000);
              }
              //that.geneplots = res.data.output[0];
              that.geneloading = false;
            }
          })
          .catch(function(res) {
            console.log(res);
          });
      }
    },

    evoluPlot(clickgene) {
      if (this.checkInput()) {
        var that = this;
        that.evoluloading = true;
        this.$http
          .get("/tiger/scimmudiffexpdetailevlou.php", {
            params: {
              cancer: this.cancer,
              gloclu: this.gloclu,
              subclu: this.subclu.join(","),
              gene: clickgene
            }
          })
          .then(function(res) {
            if (res.data.status == 0) {
              if (res.data.output[0] === "0") {
                that.evolushow=false
                //alert("no gene file");
              } else {
                that.evolushow=true
                setTimeout((that.evoluplots = res.data.output[0]), 1000);
              }
              //that.evoluplots = res.data.output[0];
              that.evoluloading = false;
            }
          })
          .catch(function(res) {
            console.log(res);
          });
      }
    }
  },

  computed: {
    imgUrlWgcna: function() {
      return "tiger/img/" + this.imgpath + ".png";
    },
    imgUrlBox: function() {
      return "tiger/img/" + this.imgpathBox + ".png";
    },
    imgUrlBar: function() {
      return "tiger/img/" + this.imgpathBar + ".png";
    },
    imgUrlEvo: function() {
      return "tiger/img/" + this.imgpathEvo + ".png";
    }
  },

  components: {
    "v-goTop": goTop
  }
};
</script>

<style>
</style>


