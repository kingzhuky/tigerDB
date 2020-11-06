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
                    <i class="el-icon-setting"></i>Optional
                  </template>
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
          <p class="card-title">Scatter Plot of Co-expression</p>
          <el-row v-loading="loading" v-show="resultShow" class="detailimg">
            <img id="scimmuscater" :src="imgUrlWgcna" />
          </el-row>
          <div v-show="!resultShow" id="norult" v-loading="loading">No result</div>
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
    gloclu: {
      type: String,
    },
  },

  data() {
    return {
      tableLoading: "",
      normalMed: "None",
      corMed: "spearman",
      imgpath: "",
      loading: true,
      clickgene: "",
      cluster: "",
      resultShow: true,
    };
  },

  methods: {
    clickPlot() {
      this.Plot(this.clickgene, this.cluster);
    },

    Plot(clickgene, cluster) {
      (this.clickgene = clickgene), (this.cluster = cluster);
      var that = this;
      that.loading = true;
      that.resultShow = true;
      this.$http
        .get("/tiger/scimmucoexpdetail.php", {
          params: {
            cancer: this.cancer,
            gene: this.gene,
            gloclu: this.gloclu,
            clickgene: clickgene,
            cluster: cluster.replace(" ", "-"),
            method: this.corMed,
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


