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
                    class="detailtable"
                    border
                    max-height="600"
                    :data="tableData"
                    v-loading="loading"
                    :cell-style="tableCellStyle"
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
                      :sort-orders="['descending', null]"
                      align="center"
                      width="85%"
                    ></el-table-column>
                  </el-table>
                </div>
              </el-col>
              <el-col :span="12" >
                <el-row v-loading="plotloading">
                  <el-col :span="11" push="1" v-show="evolushow2">
                    <p class="imgtitle">Tissue in {{celltype_1}} </p>
                    <img
                      id="singleimg"
                      fit="fill"
                      width="100%"
                      :src="'tiger/img/' + crossimg[0]+ '.png'"
                      @click="previewImg(['tiger/img/' + crossimg[0]+'.png','tiger/img/' + crossimg[1]+'.png','tiger/img/' + crossimg[0]]+'.png')">
                  </el-col>
                  <el-col :span="11" push="1" v-show="evolushow2">
                    <p class="imgtitle">Tissue in {{celltype_2}} </p>
                    <img
                      id="singleimg"
                      fit="fill"
                      width="100%"
                      :src="'tiger/img/' + crossimg[2] + '.png'"
                      @click="previewImg(['tiger/img/' + crossimg[0]+'.png','tiger/img/' + crossimg[1]+'.png','tiger/img/' + crossimg[0]]+'.png')">
                  </el-col>
                  
                </el-row>
                <el-row v-loading="plotloading">
                  <el-col :span="11" push="1" v-show="evolushow2" style="position:relative;left:20px;top:0px;">
                    <p class="imgtitle">UMAP Plot of {{gene_1}} Expression in {{celltype_1}}</p>
                    <img
                      id="singleimg"
                      fit="fill"
                      width="100%"
                      :src="'tiger/img/' + crossimg[1]+ '.png'"
                      @click="previewImg(['tiger/img/' + crossimg[0]+'.png','tiger/img/' + crossimg[1]+'.png','tiger/img/' + crossimg[0]]+'.png')">
                  </el-col>
                  <el-col :span="11" v-show="evolushow2" style="position:relative;left:20px;top:0px;">
                    <p class="imgtitle">UMAP Plot of {{gene_2}} Expression in {{celltype_2}}</p>
                    <img
                      id="singleimg"
                      fit="fill"
                      width="100%"
                      :src="'tiger/img/' + crossimg[3]+ '.png'"
                      @click="previewImg(['tiger/img/' + crossimg[0]+'.png','tiger/img/' + crossimg[1]+'.png','tiger/img/' + crossimg[0]]+'.png')">
                  </el-col>
                </el-row>
                <!-- <el-row v-loading="plotloading">
                  <el-col :span="11" push="1" v-show="evolushow2">
                    <p class="imgtitle">Tissue in {{celltype_1}} </p>
                    <img
                      id="singleimg"
                      fit="fill"
                      width="100%"
                      :src="'tiger/img/' + crossimg[5]"
                      @click="previewImg(['tiger/img/' + crossimg[0]+'.png','tiger/img/' + crossimg[1]+'.png','tiger/img/' + crossimg[0]]+'.png')">
                  </el-col>
                  <el-col :span="11" v-show="evolushow2" style="position:relative;left:20px;top:0px;">
                    <p class="imgtitle">UMAP Plot of {{gene1}} Expression in {{celltype_1}}</p>
                    <img
                      id="singleimg"
                      fit="fill"
                      width="100%"
                      :src="'tiger/img/' + crossimg[7]"
                      @click="previewImg(['tiger/img/' + crossimg[0]+'.png','tiger/img/' + crossimg[1]+'.png','tiger/img/' + crossimg[0]]+'.png')">
                  </el-col>
                </el-row> -->
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
import {
  scrollRow,
  toTarget,
  gStyle,
  move,
  stop,
  onesidecolor,
} from "../../../static/js/utils.js";

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
      plotloading: false,
      celltype_1: '',
      celltype_2: '',
      gene_1: '',
      gene_2: '',
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
          // console.log(that.tableDataheader)
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
              // console.log(imgpath[0])
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
          }
        })
        .catch(function (res) {
          console.log(res);
        });
    },
    heandleclick(row, column) {
      if (column["label"] !== "gene") {
        this.evolushow2 = false;
        this.plotloading = true;
        this.crossimg = [];
        this.celltype_1 = column["label"].split(",").pop().split('|')[0]
        this.celltype_2 = column["label"].split('|').pop()
        this.gene_1 = row["gene"].split('_')[0]
        this.gene_2 = row["gene"].split('_').pop()
        this.crossPlot(row["gene"], column["label"]);
        this.plotloading = false;
        this.evolushow2 = true;
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
    tableCellStyle({ row, column }) {
      if (row[column["property"]] === null || column["property"] == 'gene') {
        return {
          background: "white",
        };
      }
      var mycolr = onesidecolor(0,4,parseFloat(row[column["property"]]));
      return {
        background: mycolr["background"],
        color: mycolr["color"],
      };
    },
  },
  components: {
    "v-goTop": goTop,
  },
};
</script>

<style>
.detailtable .el-table__body tr>td:hover {
  cursor: pointer;
  outline: 1px solid rgba(82, 168, 236, .8);
  outline-offset: -1px;
  -webkit-box-shadow: 0 0 8px rgba(82, 168, 236, .6);
  box-shadow: 0 0 8px rgba(82, 168, 236, .6);
}

.detailtable .el-table__body tr>th:hover {
  background-color: black;
}

</style>


