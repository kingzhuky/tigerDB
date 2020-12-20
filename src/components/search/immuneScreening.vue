<template>
  <div>
    <div class="textitem">
      <div class="tablewidth" v-loading="cardLoading">
        <el-card v-show="diffExpResponShow">
          <el-row v-loading="diffExpResponloading">
            <p class="card-title">Informations</p>
            <el-table :data="articleData" style="width: 100%">
              <el-table-column type="expand">
                <template slot-scope="props">
                  <el-form label-position="left" inline class="demo-table-expand">
                    <el-form-item label="Ariticle">
                      <span>{{ props.row.ariticle_name }}</span>
                    </el-form-item>
                    <br>
                    <el-form-item label="PMID">
                      <span>{{ props.row.PMID }}</span>
                    </el-form-item>
                    <br>
                   <el-form-item label="First author">
                      <span>{{ props.row.First_author }}</span>
                    </el-form-item>
                    <br>
                     <el-form-item label="Journal">
                      <span>{{ props.row.Journal }}</span>
                    </el-form-item>
                    <br>
                    <el-form-item label="Abstract">
                      <span>{{ props.row.Abstract }}</span>
                    </el-form-item>
                  </el-form>
                </template>
              </el-table-column>
              <el-table-column label="Gene" prop="GENE_SYMBOL"></el-table-column>
              <el-table-column label="Dataset" prop="Dataset_name"></el-table-column>
              <el-table-column label="Cancer Type" prop="Cancer_type"></el-table-column>
              <el-table-column label="Model" prop="Model"></el-table-column>
              <el-table-column label="Log2FC" prop="Log2FoldChange"></el-table-column>
              <el-table-column label="Relation to immunity" prop="RelationToImmunity"></el-table-column>
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
    conditi: {type: String},
    title: {type: String},
    seargene: {type: String}
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
    }
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
        this.articleDetail();
      }
    },
    articleDetail() {
      var that = this;
      that.cardLoading = true;
      this.$http
        .get("/tiger/immunescreendetail.php", {
          params: {
            gene: this.seargene,
          },
        })
        .then(function (res) {
          that.articleData = res.data.list;
          that.cardLoading = false;
        })
        .catch(function (res) {
          console.log(res);
        });
    }
  }
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
