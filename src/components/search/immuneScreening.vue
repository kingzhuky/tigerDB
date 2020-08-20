<template>
  <div>
    <div class="textitem">
      <div class="tablewidth" v-loading="cardLoading">
        <el-card v-show="diffExpResponShow">
          <p class="card-title">Different levels in different immune related screenings</p>
          <el-row v-loading="diffExpResponloading">
            <div id="immuneScreening" class="scaterPlot" style="width: 600px;height:400px;"></div>

          <p class="card-title">Article Infomations</p>
          <el-table :data="articleData" style="width: 100%" v-loading="artloading">
            <el-table-column prop="title" label width="180"></el-table-column>
            <el-table-column prop="value" label></el-table-column>
          </el-table>
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
    seargene:""
  },

  data() {
    return {
      expands: [],
      diffExpResponShow: true,
      cardLoading:true,
      diffExpResponloading: false,
      diffExpRespontableData: [],
      loading: false,
      imgpathBox: "",
      getPlotUrl: "",
      detailimgShow:true,
      articleData:[],
      artloading:true,
      oldseargene:""
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
      this.plot()
    });
  },

  methods: {
    plot(){
      if ((this.oldseargene !== this.seargene) | (this.oldseargene === "")) {
        this.oldseargene = this.seargene;
        this.getTableData(this.seargene, "Responder");
        this.artivcleDetail("B16_NK")
      }
      
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
  

    getTableData(gene, conditi) {
      this.cardLoading=true
      this.$http
        .get("/tiger/homeresponse.php", {
          params: {
            gene: gene,
            conditi: conditi,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.draw_chart(res.data.list,conditi);
            //this.diffExpRespontableData = res.data.datatable;
            this.cardLoading=false
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    draw_chart(data) {
      var targetdiv = document.getElementById("immuneScreening");
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      let myChart_mercor = window.echarts.init(targetdiv);

      let option = {
        xAxis: {},
        yAxis: {},
        tooltip: {
          formatter: "{c}",
        },
        series: [
          {
            symbolSize: 20,
            data: data,
            type: "scatter",
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
};
</script>


<style>

div#immuneScreening {
    margin: 0 auto;
}
</style>
