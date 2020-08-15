<template>
  <div>
    <el-card v-loading="detailload" class="decard" v-if="wershow">
      <!-- <p class="card-title">{{this.seargene}} Information</p>
      <div class="textitem">
        <div class="tablewidth">
          <el-table
            :show-header="false"
            ref="singleTable"
            :data="werdetailgene"
            stripe
            style="width: 100%"
          >
            <el-table-column property="title" label width="300" align="right">
              <template scope="scope">
                <span class="resAndSug">{{scope.row.title}}</span>
              </template>
            </el-table-column>

            <el-table-column label>
              <template slot-scope="scope">
                <a v-html="scope.row.name"></a>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div> -->


         <p class="card-title">{{this.seargene}} Infomations</p>
          <el-table :data="articleData" style="width: 100%" v-loading="artloading">
            <el-table-column prop="title" label width="180"></el-table-column>
            <el-table-column prop="value" label></el-table-column>
          </el-table>



    </el-card>

    <br />
    <div class="textitem">
      <div class="tablewidth">
        <el-card v-show="ReactomeShow">
          <p class="card-title">Reactome Pathway</p>
          <el-row v-loading="ReactomeLoading" class="detailimg">
            <el-table :data="ReactomeTableData" style="width: 100%">
              <el-table-column prop="ensembl" label="Ensembl" width="180">
              </el-table-column>
              <el-table-column prop="reactomeid" label="reactome ID" width="180"></el-table-column>
              <el-table-column label="reactome URL">
                  <template slot-scope="scope">
                <a v-html="scope.row.reactomeurl"></a>
              </template>
              </el-table-column>
              <el-table-column prop="description" label="Description">
              </el-table-column>
              <el-table-column prop="source" label="Source"></el-table-column>
            </el-table>
          </el-row>
        </el-card>
      </div>
    </div>

    <br />
    <div class="textitem">
      <div class="tablewidth">
        <el-card v-show="drugshow">
          <p class="card-title">Drug-Gene Interaction</p>
          <el-row v-loading="Drugloading" class="detailimg">
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
        </el-card>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    seargene: String,
  },
  data() {
    return {
      getdetailgene: "m6a2target/getdetailgene",
      detailgene: [],
      articleData: [],
      werdetailgene: [],
      detailload: true,
      targetshow: false,
      wershow: true,
      tableData: [],
      ReactomeTableData:[],
      ReactomeLoading:false,
      ReactomeShow:true,
      drugshow: false,
      Drugloading:false
    };
  },


  mounted: function() {
     this.getdatagene()
     this.tableDetail()
     this.getdataReactome()
  },
  methods: {
    getdatagene() {
      var that = this;
      that.detailload = true;
      this.$http
        .get("/tiger/immunescreendetail.php", {
          params: {
            tabl: "home_geneinfo",
            colu: "Symbol",
            coluvalue: this.seargene
          }
        })
        .then(function(res) {
          that.articleData = res.data.list;
          that.detailload = false;
          //}
        })
        .catch(function(res) {
          console.log(res);
        });
    },

    getdataReactome() {
      this.ReactomeShow=true
      this.ReactomeLoading = true;
      this.$http
        .get("/tiger/searchReactome.php", {
          params: {
            coluvalue: this.seargene,
          },
        })
        .then((res) => {
          (this.ReactomeTableData = res.data.list),
            (this.ReactomeLoading = false);
          if (this.ReactomeTableData.length != 0) {
            this.ReactomeShow = true;
          }
        });
    },

    tableDetail(gene) {
      var that = this;
      that.drugloading = true;
      this.$http
        .get("/dgidb/api/v2/interactions.json", {
          params: {
            genes: gene,
          },
        })
        .then(function (res) {
          if (res.data.matchedTerms[0]["interactions"].length!==0) {
            that.drugshow = true;
            that.drugloading = false;
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
  },
};
</script>


<style>
.decard > .el-card__header {
  background-color: rgb(20, 146, 140) !important;
  font-weight: 700 !important;
  font-size: 25px !important;
}
</style>
