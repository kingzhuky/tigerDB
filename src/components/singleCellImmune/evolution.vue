<template>
  <div>
    <el-row id="coExpInput">
      <br />
      <br />
      <el-col :span="8" :offset="6">
        <el-autocomplete
          v-model="searchinput"
          placeholder="Please Input Gene Symbol"
          :fetch-suggestions="querySearchAsyncA"
          @keyup.enter.native="searchClick"
        ></el-autocomplete>
      </el-col>
      <el-col :span="4">
        <el-button id="homebt" @click="searchClick" icon="el-icon-search"></el-button>
      </el-col>
    </el-row>
    <br />
    <div class="detail-card">
      <div class="infor" v-loading="evoluloading">
        <el-card v-for="gloclu in gloclures" :key="gloclu" class="overiewcard">
          <p class="card-title">{{gloclu}}</p>
          <el-row class="detailimg">
            <el-col :span="10" :offset="1">
              <p class="imgtitle">Pseudo-time of cells</p>
              <img
                id="singleimg"
                fit="fill"
                width="450px"
                :src="'tiger/img/'+plotsres[gloclu][0]"
                @click="previewImg(['tiger/img/'+plotsres[gloclu][0],'tiger/img/'+plotsres[gloclu][1]])">
            </el-col>
            <el-col :span="10" :offset="1">
              <p class="imgtitle">Pseudo-time of cells with {{searchinput}} exopression</p>
              <img
                id="singleimg"
                fit="fill"
                width="450px"
                :src="'tiger/img/'+plotsres[gloclu][1]"
                @click="previewImg(['tiger/img/'+plotsres[gloclu][1],'tiger/img/'+plotsres[gloclu][0]])">
            </el-col>
          </el-row>
        </el-card>
      </div>

      <v-goTop></v-goTop>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    cancer: String,
    gloCluoptions: Array,
  },
  data() {
    return {
      sestate: false,
      tableShow: false,
      searchinput: "CXCL13",
      isShow: false,
      gloclures: [],
      plotsres: {},
    };
  },

  methods: {
    reset() {
      (this.gloclures = []), (this.plotsres = {});
    },
    checkInput() {
      if (this.searchinput.trim() === "") {
        alert("please input gene");
        return false;
      }
      return true;
    },
    evoluPlot(cancer, gloclu, gene) {
      if (this.checkInput()) {
        var that = this;
        that.evoluloading = true;
        this.$http
          .get("/tiger/scimmudiffexpdetailgene.php", {
            params: {
              type: "evolution",
              cancer: cancer,
              gloclu: gloclu,
              gene: gene,
            },
          })
          .then(function (res) {
            if (res.data.status == 0) {
              if (res.data.output[0] === "0") {
                that.evolushow = false;
                //alert("no gene file");
              } else {
                that.evolushow = true;
                Vue.set(that.plotsres, gloclu, res.data.output[0].split(","))
              }
              //that.evoluplots = res.data.output[0];
              that.evoluloading = false;
            }
          })
          .catch(function (res) {
            console.log(res);
          });
      }
    },
    querySearchAsyncA(queryString, cb) {
      this.$http
        .get("/m6a2target/genesug", {
          params: {
            gene: this.searchinput,
            species: "Human",
          },
        })
        .then((res) => {
          cb(res.data.datasetinfo);
        });
    },
    searchClick() {
      // if(this.sestate){
      //   return false
      // }
      // this.sestate = false;
      this.reset();
      this.isShow = true;
      for (let gloclu of this.gloCluoptions) {
        this.gloclures.push(gloclu["GlobalCluster"]);
        this.evoluPlot(this.cancer, gloclu["GlobalCluster"], this.searchinput);
      }
      // this.sestate = true;
      // return this.sestate
    },
    previewImg(url){
      this.$hevueImgPreview({
        imgList: url,
        multiple: true, // 开启多图预览模式
        keyboard: true,
        nowImgIndex: 0, // 多图预览，默认展示第二张图片
        mainBackground: 'rgba(0, 0, 0, .5)', // 整体背景颜色
        closeColor: 'rgba(255,255,255,.5)'
      })
    },
  },
};
</script>


<style>
.el-table__fixed {
  cursor: not-allowed;
}

#coExpInput .el-autocomplete {
  width: 100%;
}

#scCoExpTable th {
  left: 70px !important;
  height: 140px !important;
}
</style>
