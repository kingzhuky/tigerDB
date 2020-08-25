<template>
  <div>
    <div class="textitem">
      <div class="tablewidth" v-loading="cardLoading">
        <el-card v-show="diffExpResponShow">
          <!-- <p class="card-title">Different levels in different immune related screenings</p> -->
          <el-row v-loading="diffExpResponloading">
            <!-- <div id="immuneScreening" class="scaterPlot" style="width: 600px;height:400px;"></div> -->

            <p class="card-title">Infomations</p>
            <el-table :data="articleData" style="width: 100%">
              <el-table-column type="expand">
                <template slot-scope="props">
                  <el-form label-position="left" inline class="demo-table-expand">
                   
                    <el-form-item label="Ariticle">
                      <span>{{ props.row.ariticle_name }}</span>
                    </el-form-item>
                    <el-form-item label="Abstract">
                      <span>{{ props.row.Abstract }}</span>
                    </el-form-item>
                  </el-form>
                </template>
              </el-table-column>
              <el-table-column label="Gene" prop="GENE_SYMBOL"></el-table-column>
              <el-table-column label="Dataset" prop="Dataset_name"></el-table-column>
              <el-table-column label="Log2FC" prop="Log2FoldChange"></el-table-column>
              <el-table-column label="Cancer Type" prop="Cancer_type"></el-table-column>
              <el-table-column label="Model" prop="Model"></el-table-column>
              <el-table-column label="PMID" prop="PMID"></el-table-column>
            </el-table>

            <!-- <el-table :data="articleData" style="width: 100%" >
              <el-table-column prop="title" label width="180"></el-table-column>
              <el-table-column prop="value" label></el-table-column>
            </el-table>-->
          </el-row>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    conditi: "",
    title: "",
    seargene: "",
  },

  data() {
    return {
      expands: [],
      diffExpResponShow: true,
      cardLoading: true,
      diffExpResponloading: false,
      diffExpRespontableData: [],
      loading: false,
      imgpathBox: "",
      getPlotUrl: "",
      detailimgShow: true,
      articleData: [],
      oldseargene: "",
    };
  },

  computed: {
    imgUrlBox: function () {
      return "tiger/img/" + this.imgpathBox + ".png";
    },
    // imgUrlBar: function() {
    //   return "tiger/img/" + this.imgpathBar + ".png";
    // }
  },

  mounted() {
    this.$nextTick(() => {
      this.plot();
    });
  },

  methods: {
    plot() {
      if ((this.oldseargene !== this.seargene) | (this.oldseargene === "")) {
        this.oldseargene = this.seargene;
        //this.getTableData(this.seargene, "Responder");
        this.artivcleDetail();
      }
    },
    artivcleDetail() {
      var that = this;
      that.cardLoading = true;
      this.$http
        .get("/tiger/immunescreendetail.php", {
          params: {
            gene: this.seargene,
          },
        })
        .then(function (res) {
          // if (res.data.status == 0) {
          //console.log(res.data.matchedTerms[0]["interactions"]);
          that.articleData = res.data.list;
          //that.imgpath = res.data.output[2];
          that.cardLoading = false;
          //}
        })
        .catch(function (res) {
          console.log(res);
        });
    },

    // getTableData(gene, conditi) {
    //   this.cardLoading=true
    //   this.$http
    //     .get("/tiger/homeresponse.php", {
    //       params: {
    //         gene: gene,
    //         conditi: conditi,
    //       },
    //     })
    //     .then((res) => {
    //       if (res.data.status === 200) {
    //         //this.draw_chart(res.data.list,conditi);
    //         //this.diffExpRespontableData = res.data.datatable;
    //         this.cardLoading=false
    //       }
    //     })
    //     .catch((error) => {
    //       console.log(error);
    //     });
    // },

    // draw_chart(data) {
    //   var targetdiv = document.getElementById("immuneScreening");
    //   //let myChart_mercor = this.$echarts.init(targetdiv);
    //   //cdn替换为
    //   let myChart_mercor = window.echarts.init(targetdiv);

    //   let option = {
    //     xAxis: {},
    //     yAxis: {},
    //     tooltip: {
    //       formatter: "{c}",
    //     },
    //     series: [
    //       {
    //         symbolSize: 20,
    //         data: data,
    //         type: "scatter",
    //       },
    //     ],
    //   };

    //   myChart_mercor.clear();
    //   myChart_mercor.setOption(option);
    //   window.onresize = function () {
    //     myChart_mercor.resize();
    //   };
    // },
  },
};
</script>


<style>
div#immuneScreening {
  margin: 0 auto;
}
.demo-table-expand {
  font-size: 0;
}
.demo-table-expand label {
  width: 90px;
  color: #99a9bf;
}
.demo-table-expand .el-form-item {
  margin-right: 0;
  margin-bottom: 0;
}
</style>
