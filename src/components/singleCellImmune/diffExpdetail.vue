<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor">
        <el-card class="box-card-return">
          <div class="text item">
            <h1 style="font-weight: bold; font-size: 25px; text-align: center">
              Cancer Type: {{ cancer }}<br />Cell Type:
              {{ gloclu == "All" ? celltype : gloclu }}<br />Gene Symobl:
              {{ gene }}
            </h1>
          </div>
        </el-card>
      </div>

      <div class="infor">
        <el-card>
          <el-row v-loading="geneloading">
            <el-row
              class="scdetailimg"
              v-show="geneshow"
              :gutter="20"
              type="flex"
              justify="space-around"
              style="height: 280px"
            >
              <el-col :span="4">
                <p class="imgtitle">Cell Types Distribution</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="100%"
                  :src="'tiger/img/' + geneplots.split(',')[0] + '.png'"
                  @click="
                    previewImg(0, [
                      'tiger/img/' + geneplots.split(',')[0] + '.png',
                      'tiger/img/' + geneplots.split(',')[1] + '.png',
                      'tiger/img/' + geneplots.split(',')[2] + '.png',
                      'tiger/img/' + geneplots.split(',')[3] + '.png',
                      'tiger/img/' + geneplots.split(',')[4] + '.png',
                    ])
                  "
                />
              </el-col>
              <el-col :span="4">
                <p class="imgtitle">Tissue Types Distribution</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="100%"
                  :src="'tiger/img/' + geneplots.split(',')[1] + '.png'"
                  @click="
                    previewImg(1, [
                      'tiger/img/' + geneplots.split(',')[0] + '.png',
                      'tiger/img/' + geneplots.split(',')[1] + '.png',
                      'tiger/img/' + geneplots.split(',')[2] + '.png',
                      'tiger/img/' + geneplots.split(',')[3] + '.png',
                      'tiger/img/' + geneplots.split(',')[4] + '.png',
                    ])
                  "
                />
              </el-col>
              <el-col :span="4">
                <div class="imgspan">
                  <p class="imgtitle">{{ gene }} Expression</p>
                  <img
                    id="singleimg"
                    fit="fill"
                    width="100%"
                    :src="'tiger/img/' + geneplots.split(',')[3] + '.png'"
                    @click="
                      previewImg(3, [
                        'tiger/img/' + geneplots.split(',')[0] + '.png',
                        'tiger/img/' + geneplots.split(',')[1] + '.png',
                        'tiger/img/' + geneplots.split(',')[2] + '.png',
                        'tiger/img/' + geneplots.split(',')[3] + '.png',
                        'tiger/img/' + geneplots.split(',')[4] + '.png',
                      ])
                    "
                  />
                </div>
              </el-col>
              <el-col :span="4">
                <p class="imgtitle">{{celltype}} Cell Type Distribution Difference</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="100%"
                  :src="'tiger/img/' + geneplots.split(',')[2] + '.png'"
                  @click="
                    previewImg(2, [
                      'tiger/img/' + geneplots.split(',')[0] + '.png',
                      'tiger/img/' + geneplots.split(',')[1] + '.png',
                      'tiger/img/' + geneplots.split(',')[2] + '.png',
                      'tiger/img/' + geneplots.split(',')[3] + '.png',
                      'tiger/img/' + geneplots.split(',')[4] + '.png',
                    ])
                  "
                />
              </el-col>
              <el-col :span="4">
                <div class="imgspan">
                  <p class="imgtitle">{{ gene }} Expression Difference</p>
                  <img
                    id="singleimg"
                    fit="fill"
                    width="100%"
                    :src="'tiger/img/' + geneplots.split(',')[4] + '.png'"
                    @click="
                      previewImg(4, [
                        'tiger/img/' + geneplots.split(',')[0] + '.png',
                        'tiger/img/' + geneplots.split(',')[1] + '.png',
                        'tiger/img/' + geneplots.split(',')[2] + '.png',
                        'tiger/img/' + geneplots.split(',')[3] + '.png',
                        'tiger/img/' + geneplots.split(',')[4] + '.png',
                      ])
                    "
                  />
                </div>
              </el-col>
            </el-row>
            <el-col
              :span="16"
              :offset="2"
              v-show="!geneshow"
              v-loading="loading"
            >
              <div id="norult">No result</div>
            </el-col>
          </el-row>
          <br />
          <br />
        </el-card>
        <br />
        <el-card v-loading="detailload" class="decard" v-if="wershow">
          <p class="card-title">Gene Information</p>
          <el-table
            :data="articleData"
            style="width: 100%"
            v-loading="artloading"
          >
            <!-- <el-table-column prop="title" label width="180"></el-table-column> -->
            <el-table-column
              prop="title"
              label
              style="font-weight: 700"
              width="250"
            >
              <template slot-scope="{ row: { title } }" class="csstitle">
                <span class="csstitle" v-if="title === 'Symbol'"
                  >Gene Symbol</span
                >
                <span class="csstitle" v-else-if="title === 'description'"
                  >Description</span
                >
                <span class="csstitle" v-else-if="title === 'type_of_gene'"
                  >Gene Type</span
                >
                <span class="csstitle" v-else-if="title === 'Synonyms'"
                  >Aliases</span
                >
                <span
                  class="csstitle"
                  v-else-if="title === 'Other_designations'"
                  >Summary</span
                >
                <span class="csstitle" v-else-if="title === 'GeneID'"
                  >Entrez Gene</span
                >
                <span class="csstitle" v-else>{{ title }}</span>
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
    celltype: { type: String },
    gloclu: {
      type: String,
    },
    clickGene: {
      type: String,
    },
  },

  data() {
    return {
      // overviewimg: "",
      geneshow: true,
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
    clickPlot() {
      this.genePlot(this.clickGene);
      //this.evoluPlot(this.clickGene);
    },
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
              gloclu: gloclu,
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              if (res.data.output[0] === "0" || res.data.output2[0] === "0") {
                that.geneshow = false;
              } else {
                that.geneshow = true;
                that.geneplots =
                  res.data.output2[0].split(",")[0] + "," + res.data.output[0];
              }
              //that.geneplots = res.data.output[0];
              // console.log(that.geneloading)
              that.geneloading = false;
              // console.log(that.geneloading)
            }
          })
          .catch(function (res) {
            console.log(res);
          });
      }
    },
    previewImg(index, url) {
      this.$hevueImgPreview({
        imgList: url,
        multiple: true, // 开启多图预览模式
        keyboard: true,
        nowImgIndex: index, // 多图预览，默认展示第二张图片
        mainBackground: "rgba(0, 0, 0, .5)", // 整体背景颜色
        closeColor: "rgba(255,255,255,.5)",
      });
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


