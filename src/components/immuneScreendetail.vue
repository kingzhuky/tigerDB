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
          <p class="card-title">Article Infomations</p>
          <el-table :data="articleData" style="width: 100%" v-loading="artloading">
            <el-table-column prop="title" label width="180"></el-table-column>
            <el-table-column prop="value" label></el-table-column>
          </el-table>
          <div v-show="drugshow">
            <p class="card-title">drug-gene interactions</p>
            <el-row v-loading="loading" class="detailimg">
              <el-table :data="tableData" style="width: 100%">
                <el-table-column prop="drugName" label="Drug" width="180">
                  <template slot-scope="scope">
                    <a
                      :href="'http://dgidb.org/drugs/'+scope.row.drugName"
                      target="_blank"
                      class="buttonText"
                    >{{scope.row.drugName}}</a>
                  </template>
                </el-table-column>
                <el-table-column prop="interactionTypes" label="Interaction Type" width="180"></el-table-column>
                <el-table-column prop="sources" label="sources">
                  <template slot-scope="scope">
                    <a
                      v-for="source in scope.row.sources"
                      :key="source"
                      :href="'http://dgidb.org/sources/'+source"
                      target="_blank"
                      class="buttonText"
                    >{{source}},</a>
                  </template>
                </el-table-column>
                <el-table-column prop="pmids" label="PMIDs">
                  <template slot-scope="scope">
                    <a
                      v-for="pmid in scope.row.pmids"
                      :key="pmid"
                      :href="'https://www.ncbi.nlm.nih.gov/pubmed/?term='+pmid"
                      target="_blank"
                      class="buttonText"
                    >{{pmid}},</a>
                  </template>
                </el-table-column>
                <el-table-column prop="score" label="Score"></el-table-column>
              </el-table>
            </el-row>
          </div>
        </el-card>
      </div>
      <v-goTop></v-goTop>
    </div>
  </transition>
</template>

<script>
import goTop from "./public/goTop";

//import { downloadFile } from "../../../static/js/utils.js";

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
  },

  data() {
    return {
      drugshow: false,
      tableLoading: "",
      normalMed: "None",
      normalGene: "",
      logScale: "FALSE",
      imgpath: "",
      loading: true,
      artloading: true,
      tableData: [],
      articleData: [],
    };
  },
  mounted() {
    this.tableDetail(this.gene);
    this.artivcleDetail(this.cancer);
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
      this.Plot(this.gene, this.cancer);
    },

    tableDetail(gene) {
      var that = this;
      that.loading = true;
      this.$http
        .get("/dgidb/api/v2/interactions.json", {
          params: {
            genes: gene,
          },
        })
        .then(function (res) {
          // if (res.data.status == 0) {
          //console.log(res.data.matchedTerms[0]["interactions"]);
          if (res.data.matchedTerms[0]["interactions"]) {
            that.drugshow = true;
            that.tableData = res.data.matchedTerms[0]["interactions"];
            //that.imgpath = res.data.output[2];
            that.loading = false;
          } else {
            that.drugshow = false;
          }

          //}
        })
        .catch(function (res) {
          console.log(res);
        });
    },

    artivcleDetail(sample) {
      var that = this;
      that.artloading = true;
      this.$http
        .get("/tiger/immunescreendetail.php", {
          params: {
            tabl: "immunescreenartle",
            colu: "dataset_id",
            coluvalue: sample,
          },
        })
        .then(function (res) {
          // if (res.data.status == 0) {
          //console.log(res.data.matchedTerms[0]["interactions"]);
          that.articleData = res.data.list;
          //that.imgpath = res.data.output[2];
          that.artloading = false;
          //}
        })
        .catch(function (res) {
          console.log(res);
        });
    },

    Plot(gene, mergedatasets) {
      if (this.checkInput()) {
        var that = this;
        that.loading = true;
        this.$http
          .get("/tiger/responseDiff.php", {
            params: {
              gene: gene,
              mergedatasets: mergedatasets,
              responder: "CR,PR",
              noresponder: "PD,SD",
              normalMed: this.normalMed,
              normalGene: this.normalMed == "None" ? "None" : this.normalGene,
              logScale: this.logScale,
              datatype: "png",
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              that.imgpath = res.data.output[2];
              that.loading = false;
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


