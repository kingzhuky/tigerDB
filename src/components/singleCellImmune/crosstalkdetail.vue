<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor">
        <el-card class="box-card-return">
          <div class="text item">
            <h1
              style="font-weight: bold;font-size:25px;text-align:center"
            >Cancer Type: {{cancer}}<br>Cell Type 1: {{gloclu}}<br>Cell Type 2: {{celltype2}}</h1>
          </div>
        </el-card>
      </div>

      <div class="infor">
        <el-card>
          <el-row v-loading="evoluloading">
            <el-row class="scdetailimg">
              <el-col :span="12" :offset="0" v-show="resultShow">
                <div class="detailimg">
                  <el-table
                    ref="singleTable"
                    border
                    max-height="420"
                    :data="tableData"
                    v-loading="loading"
                    :row-style="tableCellStyle"
                    header-row-class-name="tableHead"
                    
                    @cell-click="heandleclick"
                    style="100%"
                  >
                    <el-table-column
                      v-for="(item,index) in tableDataheader"
                      :key="index"
                      :property="item"
                      :label="item"
                      sortable
                      cursor="pointer"
                      :sort-orders="['ascending', 'descending', null]"
                      align="center"
                      width="85%"
                    ></el-table-column>
                  </el-table>
                </div>
              </el-col>
              <el-col :span="4" v-show="evolushow2" style="position:relative;left:20px;top:0px;">
                <p class="imgtitle">Cell Types</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="100%"
                  :src="'tiger/img/' + crossimg[0]+ '.png'"
                  @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + evoluplots.split(',')[1],'tiger/img/' + evoluplots.split(',')[0]])">
              </el-col>
              <el-col :span="4" v-show="evolushow2" style="position:relative;left:100px;top:0px;">
                <p class="imgtitle">UMAP Plot of {{celltype2}} Types</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="100%"
                  :src="'tiger/img/' + crossimg[1] + '.png'"
                  @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + evoluplots.split(',')[1],'tiger/img/' + evoluplots.split(',')[0]])">
              </el-col>
              <el-col :span="5" v-show="evolushow2" style="position:relative;left:20px;top:0px;">
                <p class="imgtitle">Cell Types</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="100%"
                  :src="'tiger/img/' + crossimg[2]+ '.png'"
                  @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + evoluplots.split(',')[1],'tiger/img/' + evoluplots.split(',')[0]])">
              </el-col>
              <!-- <el-col :span="3" v-show="evolushow2" style="position:relative;left:100px;top:0px;">
                <p class="imgtitle">UMAP Plot of {{celltype2}} Types</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="100%"
                  :src="'tiger/img/' + crossimg[3] + '.png'"
                  @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + evoluplots.split(',')[1],'tiger/img/' + evoluplots.split(',')[0]])">
              </el-col> -->
              <!-- <el-col :span="8" :offset="1" v-show="resultShow">
                <div class="detailimg" v-loading="loading">
                  <p class="imgtitle">Differential Expression between R and NR</p>
                  <img style="position:relative;top:10px;right:0px;" width="350px" :src="imgUrlBox" />
                </div>
              </el-col>

              <el-col  :span="14" v-show="!resultShow" v-loading="loading">
                <div id="norult">No result</div>
              </el-col> -->
              <!-- <p class="card-title">tSNE</p> -->
            <!-- <el-col :span="6" v-show="evolushow2" style="position:relative;left:20px;top:0px;">
              <p class="imgtitle">Cell Types</p>
              <img
                id="singleimg"
                fit="fill"
                width="100%"
                :src="'tiger/img/' + overviewimg.split(',')[0]+'.png'"
                @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + evoluplots.split(',')[1],'tiger/img/' + evoluplots.split(',')[0]])">
            </el-col>
            <el-col :span="6" v-show="evolushow2" style="position:relative;left:100px;top:0px;">
              <p class="imgtitle">UMAP Plot of {{celltype2}} Types</p>
              <img
                id="singleimg"
                fit="fill"
                width="100%"
                :src="'tiger/img/' + evoluplots.split(',')[1]"
                @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + evoluplots.split(',')[1],'tiger/img/' + evoluplots.split(',')[0]])">
            </el-col>
            <el-col :span="12" v-show="evolushow2" style="position:relative;left:40px;top:0px;">
              <p class="imgtitle">Boxplot of {{celltype2}} Expression</p>
              <img
                id="singleimg"
                fit="fill"
                height="250px"
                :src="'tiger/img/' + evoluplots.split(',')[0]"
                @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + evoluplots.split(',')[1],'tiger/img/' + evoluplots.split(',')[0]])">
            </el-col> -->
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
    celltype2: {
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
      evolushow2: false,
      evolushow: true,
      tableLoading: "",
      normalMed: "None",
      normalGene: "",
      logScale: "FALSE",
      evoluloading: true,
      geneloading: true,
      //geneplots: "",
      evoluplots: "",
      tableData: [],
      tableDataheader: [],
      crossimg: [],
    };
  },

  methods: {
    checkInput() {
      if (this.normalMed !== "None" && this.normalGene.length == 0) {
        alert("please input Normalized celltype2 or Cell fration");
        return false;
      }
      return true;
    },
    gettableData(jsonUrl) {
      var that = this;
      this.$http
        .get("/tiger/img/" + jsonUrl + ".json")
        .then(function(res) {
          that.tableData = res.data;
          that.tableDataheader = Object.keys(res.data[0])
          console.log(that.tableDataheader)
          that.resultShow = true;
        })
        .catch(function(res) {
          // console.log(res);
        });
    },
    markerPlot(celltype2, celltype) {
      if (this.checkInput()) {
        var that = this;
        that.evoluloading = true;
        this.$http
          .get("/tiger/singlecellcross.php", {
            params: {
              cancer: this.cancer,
              celltype1: celltype,
              celltype2: celltype2,
              datatype: "table",
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              let imgpath = res.data.output[0].split(",");
              console.log(imgpath[0])
              that.gettableData(imgpath[0])
              that.evoluloading = false;
              that.evolushow2 = false;
            }
          })
          .catch(function (res) {
            console.log(res);
          });
      }
    },
    crossPlot(gene, celltypepair) {
      var that = this;
      this.$http
        .get("/tiger/singlecellcross.php", {
          params: {
            cancer: this.cancer,
            celltype1: gene,
            celltype2: celltypepair,
            datatype: "plot",
          },
        })
        .then(function (res) {
          if (res.data.status == 0) {
            let imgpath = res.data.output[0].split(",");
            console.log(imgpath)
            that.crossimg = imgpath
            that.evolushow2 = true;
          }
        })
        .catch(function (res) {
          console.log(res);
        });
    },
    heandleclick(row, column) {
      if (column["label"] !== "gene") {
        this.crossPlot(row["gene"], column["label"]);
        // toTarget(820);
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


