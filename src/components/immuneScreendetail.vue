<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor">
        <el-card class="box-card-return">
          <div class="text item">
            <h1 style="font-weight: bold; font-size: 25px; text-align: center">
              {{ gene }} -- {{ cancer }}
            </h1>
          </div>
        </el-card>
      </div>

      <div class="infor">
        <el-card>
          <div
            id="barplot"
            class="scaterPlot"
            style="width: 1300px; height: 700px"
          ></div>
          <p class="card-title">Article Infomations</p>
          <!-- <el-table :data="articleData" style="width: 100%" v-loading="artloading">
            <el-table-column prop="title" label width="180"></el-table-column>
            <el-table-column prop="value" label></el-table-column>
          </el-table> -->
          <el-table
            :data="articleData"
            style="width: 100%"
            v-loading="artloading"
          >
            <!-- <el-table-column prop="title" label width="180"></el-table-column> -->
            <el-table-column prop="title" label width="250">
              <template slot-scope="{ row: { title } }">
                <span v-if="title === 'dataset_id'">Dataset ID</span>
                <span v-else-if="title === 'Dataset_name'">Dataset Name</span>
                <span v-else-if="title === 'Cancer_type'">Cancer Type</span>
                <span v-else-if="title === 'dataset_type'">Dataset Type</span>
                <span v-else-if="title === 'article_name'">Ariticle Title</span>
                <span v-else-if="title === 'First_author'">First Author</span>
                <span v-else>{{ title }}</span>
              </template>
            </el-table-column>
            <el-table-column label>
              <template slot-scope="scope">
                <span v-if="scope.row.title === 'PMID'">
                  <a
                    :href="'https://pubmed.ncbi.nlm.nih.gov/' + scope.row.value"
                    target="_blank"
                    class="buttonText"
                    >{{ scope.row.value }}</a
                  >
                </span>
                <span v-else><a v-html="scope.row.value"></a></span>
              </template>
            </el-table-column>
          </el-table>
          <div v-show="drugshow">
            <p class="card-title">drug-gene interactions</p>
            <el-row v-loading="loading" class="detailimg">
              <el-table :data="tableData" style="width: 100%">
                <el-table-column prop="drugName" label="Drug" width="180">
                  <template slot-scope="scope">
                    <a
                      :href="'http://dgidb.org/drugs/' + scope.row.drugName"
                      target="_blank"
                      class="buttonText"
                      >{{ scope.row.drugName }}</a
                    >
                  </template>
                </el-table-column>
                <el-table-column
                  prop="interactionTypes"
                  label="Interaction Type"
                  width="180"
                ></el-table-column>
                <el-table-column prop="sources" label="sources">
                  <template slot-scope="scope">
                    <a
                      v-for="source in scope.row.sources"
                      :key="source"
                      :href="'http://dgidb.org/sources/' + source"
                      target="_blank"
                      class="buttonText"
                      >{{ source }},</a
                    >
                  </template>
                </el-table-column>
                <el-table-column prop="pmids" label="PMIDs">
                  <template slot-scope="scope">
                    <a
                      v-for="pmid in scope.row.pmids"
                      :key="pmid"
                      :href="
                        'https://www.ncbi.nlm.nih.gov/pubmed/?term=' + pmid
                      "
                      target="_blank"
                      class="buttonText"
                      >{{ pmid }},</a
                    >
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
    bardata: {
      type: Array,
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
    console.log(this.bardata);
    // this.tableDetail(this.gene);
    this.articleDetail(this.cancer);

    this.draw_chart(this.bardata);
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
          if (res.data.matchedTerms[0]["interactions"]) {
            that.drugshow = true;
            that.tableData = res.data.matchedTerms[0]["interactions"];
            that.loading = false;
          } else {
            that.drugshow = false;
          }
        })
        .catch(function (res) {
          console.log(res);
        });
    },

    articleDetail(sample) {
      var that = this;
      that.artloading = true;
      this.$http
        .get("/tiger/immunescreendetail2.php", {
          params: {
            tabl: "immunescreenartle",
            colu: "dataset_id",
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
    draw_chart(data) {
      console.log(data);
      var targetdiv = document.getElementById("barplot");
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      var xdata = Object.keys(data);
      var ydata = Object.values(data);
      xdata.splice(0, 1);
      ydata.splice(0, 1);
      console.log(xdata);
      console.log(ydata.map(Number));
      let myChart_mercor = window.echarts.init(targetdiv);
      let option = {
        xAxis: {
          type: "category",
          data: xdata,
          axisLabel: {
            rotate: 45,
            interval: 0,
          },
        },
        yAxis: {
          type: "value",
        },
        series: [
          {
            data: ydata.map(Number),
            type: "bar",
          },
        ],
      };

      myChart_mercor.clear();
      myChart_mercor.setOption(option);
      window.onresize = function () {
        myChart_mercor.resize();
      };
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


