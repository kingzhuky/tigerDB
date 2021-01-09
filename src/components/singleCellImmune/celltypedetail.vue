<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor">
        <el-card class="box-card-return">
          <div class="text item">
            <h1
              style="font-weight: bold;font-size:25px;text-align:center"
            >Cancer Type: {{cancer}}<br>Global Cluster: {{gloclu}}<br>Gene Symobl: {{gene}}</h1>
          </div>
        </el-card>
      </div>

      <div class="infor">
        <el-card>
          <el-row v-loading="evoluloading">
            <el-row v-show="evolushow" class="scdetailimg">
              <!-- <p class="card-title">tSNE</p> -->
            <el-col :span="6" v-show="evolushow2" style="position:relative;left:20px;top:0px;">
              <p class="imgtitle">Cell Types</p>
              <img
                id="singleimg"
                fit="fill"
                width="100%"
                :src="'tiger/img/' + overviewimg.split(',')[0]+'.png'"
                @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + evoluplots.split(',')[1],'tiger/img/' + evoluplots.split(',')[0]])">
            </el-col>
            <el-col :span="6" v-show="evolushow2" style="position:relative;left:100px;top:0px;">
              <p class="imgtitle">UMAP Plot of {{gene}} Types</p>
              <img
                id="singleimg"
                fit="fill"
                width="100%"
                :src="'tiger/img/' + evoluplots.split(',')[1]"
                @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + evoluplots.split(',')[1],'tiger/img/' + evoluplots.split(',')[0]])">
            </el-col>
            <el-col :span="12" v-show="evolushow2" style="position:relative;left:40px;top:0px;">
              <p class="imgtitle">Boxplot of {{gene}} Expression</p>
              <img
                id="singleimg"
                fit="fill"
                height="250px"
                :src="'tiger/img/' + evoluplots.split(',')[0]"
                @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + evoluplots.split(',')[1],'tiger/img/' + evoluplots.split(',')[0]])">
            </el-col>
            </el-row>
            <el-col :span="20" :offset="2" v-show="!evolushow" v-loading="loading">
              <div id="norult">No result</div>
            </el-col>
          </el-row>
        </el-card>
        <br />
        <el-card v-loading="detailload" class="decard" v-if="wershow">
          <p class="card-title">Gene Information</p>
          <el-table :data="articleData" style="width: 100%" v-loading="artloading">
            <!-- <el-table-column prop="title" label width="180"></el-table-column> -->
            <el-table-column prop="title" label style="font-weight:700;" width="250">
              <template slot-scope="{row: {title}}" class="csstitle">
                <span class="csstitle" v-if="title === 'Symbol'">Gene Symbol</span>
                <span class="csstitle" v-else-if="title === 'description'">Description</span>
                <span class="csstitle" v-else-if="title === 'type_of_gene'">Gene Type</span>
                <span class="csstitle" v-else-if="title === 'Synonyms'">Aliases</span>
                <span class="csstitle" v-else-if="title === 'Other_designations'">Summary</span>
                <span class="csstitle" v-else-if="title === 'GeneID'">Entrez Gene</span>
                <span class="csstitle" v-else>{{title}}</span>
              </template>
            </el-table-column>
            <el-table-column prop="value" label></el-table-column>
          </el-table>
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
    celltype: { 
      type: String 
    },
    gloclu: { 
      type: String 
    },
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
      articleData: [],
      detailload: true,
      artloading: false,
      wershow: true,
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
    //   this.markerPlot(this.gene);
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
    getdatagene(gene) {
      var that = this;
      that.detailload = true;
      this.$http
        .get("/tiger/searchGene.php", {
          params: {
            tabl: "home_geneinfo",
            colu: "Symbol",
            coluvalue: gene,
          },
        })
        .then(function (res) {
          that.articleData = res.data.list;
          that.detailload = false;
          //}
        })
        .catch(function (res) {
          console.log(res);
        });
    },
    markerPlot(gene, celltype, gloclu) {
      if (this.checkInput()) {
        var that = this;
        that.evoluloading = true;
        this.$http
          .get("/tiger/scimmudiffexpdetailgene.php", {
            params: {
              cancer: this.cancer,
              celltype: celltype,
              type: "celltype",
              gene: gene,
              gloclu: gloclu
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              if (res.data.output[0] === "0") {
                that.evolushow = false;
                //alert("no gene file");
              } else {
                that.evolushow = true;
                that.evoluplots = res.data.output[0];
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
    previewImg(url){
    this.$hevueImgPreview({
      url: url,
      multiple: false, // 开启多图预览模式
      keyboard: true,
      nowImgIndex: 0, // 多图预览，默认展示第二张图片
      mainBackground: 'rgba(0, 0, 0, .5)', // 整体背景颜色
    })
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


