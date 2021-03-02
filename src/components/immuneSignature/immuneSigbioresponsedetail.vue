<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor">
        <el-card class="box-card-return">
          <div class="text item">
            <h1 style="font-weight: bold; font-size: 25px; text-align: center">
              {{ signame }} -- {{ dataset }}
            </h1>
          </div>
        </el-card>
      </div>
      <div class="infor">
        <el-card>
          <el-row v-loading="loading">
            <el-row class="scdetailimg">
              <el-col
                :span="12"
                style="position: relative; left: 20px; top: 0px"
              >
                <p class="imgtitle">Predict Response</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="100%"
                  :src="'tiger/img/' + imgpath[0] + '.png'"
                  @click="
                    previewImg(0, [
                      'tiger/img/' + imgpath[0] + '.png',
                      'tiger/img/' + imgpath[1] + '.png',
                    ])
                  "
                />
              </el-col>
              <el-col
                :span="12"
                style="position: relative; left: 40px; top: 0px"
              >
                <p class="imgtitle">{{ signame }} ROC curve</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="60%"
                  :src="'tiger/img/' + imgpath[1] + '.png'"
                  @click="
                    previewImg(1, [
                      'tiger/img/' + imgpath[0] + '.png',
                      'tiger/img/' + imgpath[1] + '.png',
                    ])
                  "
                />
              </el-col>
            </el-row>
            <!-- <el-col :span="20" :offset="2" v-show="!evolushow" v-loading="loading">
              <div id="norult">No result</div>
            </el-col> -->
          </el-row>
          <!-- <p class="card-title">Signature Informations</p>
          <el-table :data="articleData" style="width: 100%" v-loading="artloading">
            <el-table-column prop="title" label width="180"></el-table-column>
            <el-table-column prop="value" label></el-table-column>
          </el-table> -->
        </el-card>
      </div>
      <v-goTop></v-goTop>
    </div>
  </transition>
</template>

<script>
import goTop from "../public/goTop";
import { gStyle } from "../../../static/js/utils.js";

export default {
  props: {
    datatype: {
      type: String,
    },
    sign: {
      type: String,
    },
    signame: {
      type: String,
    },
    path: {
      type: String,
    },
    dataset: {},
  },

  data() {
    return {
      articleData: [],
      tableLoading: "",
      normalMed: "None",
      normalGene: "",
      loading: true,
      corMed: "pearson",
      signature: "",
      resultShow: true,
      artloading: false,
      tableData: [],
      tableDataSur: [],
      aucshow: true,
      rocshow: true,
      imgpath: "",
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
    // articleDetail(sample) {
    //   var that = this;
    //   that.artloading = true;
    //   this.$http
    //     .get("/tiger/immunescreendetail2.php", {
    //       params: {
    //         tabl: "siginfo",
    //         colu: "SignatureID",
    //         coluvalue: sample,
    //       },
    //     })
    //     .then(function (res) {
    //       that.articleData = res.data.list;
    //       that.artloading = false;
    //     })
    //     .catch(function (res) {
    //       console.log(res);
    //     });
    // },
    gettable(genestr, signatureid, datasetid) {
      var that = this;
      that.loading = true;
      this.$http
        .get("/tiger/2.5.2-generate_sigresplot.php", {
          params: {
            gene: genestr.trim().replace(" ", ""),
            dataset: datasetid,
            sigid: signatureid,
          },
        })
        .then(function (res) {
          // console.log(res.data.output[0].split(","));
          that.imgpath = res.data.output[0].split(",");
          that.loading = false;
        })
        .catch(function (res) {
          console.log(res);
        });
    },

    tableCellStyle({ row, column }) {
      var mycolr = gStyle(parseFloat(row[column["label"]]), 2.25);
      return {
        background: mycolr["background"],
        color: mycolr["color"],
      };
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
  components: {
    "v-goTop": goTop,
  },
};
</script>

<style>
</style>


