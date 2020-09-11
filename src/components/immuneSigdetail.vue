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
          <div class="wergeneinfo">
            <div id="collapseCard">
              <el-collapse>
                <el-collapse-item title="Optional" name="1">
                  <template slot="title">
                    Optional
                    <i class="el-icon-setting"></i>
                  </template>
                  <el-row class="detail1">Normalized By</el-row>
                  <el-row class="detail2">
                    <el-radio v-model="normalMed" label="None">None</el-radio>
                    <el-radio v-model="normalMed" label="gene">Gene</el-radio>
                  </el-row>
                  <el-row>
                    <el-input v-model="normalGene"></el-input>
                  </el-row>
                  <br />
                  <el-row class="detail1">Correlation Coefficient</el-row>

                  <el-row>
                    <el-radio v-model="corMed" label="pearson">Pearson</el-radio>
                    <el-radio v-model="corMed" label="spearman">Spearman</el-radio>
                  </el-row>
                  <br />
                  <el-row class="plot">
                    <el-button id="anabt" @click="clickPlot()" style="width:100%">Plot</el-button>
                  </el-row>
                </el-collapse-item>
              </el-collapse>
            </div>
          </div>
          <p class="card-title">Correlation between Custom Signature and Selected Signature</p>

          <el-row v-show="resultShow" v-loading="loading" class="detailimg">
            <img :src="imgUrlWgcna" />
          </el-row>

          <p class="card-title">Signature Infomations</p>
          <el-table :data="articleData" style="width: 100%" v-loading="artloading">
            <el-table-column prop="title" label width="180"></el-table-column>
            <el-table-column prop="value" label></el-table-column>
          </el-table>
        </el-card>
      </div>
      <v-goTop></v-goTop>
    </div>
  </transition>
</template>

<script>
import goTop from "./public/goTop";

export default {
  props: {
    gene: {
      type: String,
    },
    cancer: {
      type: String,
    },
    datatype: {
      type: String,
    },
    sign: {
      type: String,
    },
    path: {
      type: String,
    },
  },

  data() {
    return {
      articleData: [],
      tableLoading: "",
      normalMed: "None",
      normalGene: "",
      imgpath: "",
      loading: true,
      corMed: "pearson",
      signature: "",
      resultShow: true,
      artloading: false,
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
      this.Plot(this.path, this.cancer, this.sign);
    },

    artivcleDetail(sample) {
      var that = this;
      that.artloading = true;
      this.$http
        .get("/tiger/immunescreendetail.php", {
          params: {
            tabl: "siginfo",
            colu: "SignatureID",
            coluvalue: sample,
          },
        })
        .then(function (res) {
          that.articleData = res.data.list;
          that.artloading = false;
        })
        .catch(function (res) {
          console.log(res);
        });
    },

    Plot(gene, cancer, signature) {
      if (this.checkInput()) {
        var that = this;
        that.loading = true;
        that.resultShow = true;
        this.$http
          .get("/tiger/immuneSigDetail.php", {
            params: {
              Rdata: gene,
              cancer: cancer,
              signature: signature,
              normalMed: this.normalMed,
              normalGene: this.normalMed == "None" ? "None" : this.normalGene,
              corMed: this.corMed,
              datatype: "png",
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              setTimeout((that.imgpath = res.data.output[0]), 1000);

              that.loading = false;
            } else {
              that.resultShow = false;
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
  },

  components: {
    "v-goTop": goTop,
  },
};
</script>

<style>
</style>


