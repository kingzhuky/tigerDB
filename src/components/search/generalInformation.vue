<template>
  <div>
    <el-card v-loading="detailload" class="decard" v-if="wershow">
      <p class="card-title">{{this.seargene}} Information</p>
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
      </div>
    </el-card>

    <br />
    <div class="textitem">
      <div class="tablewidth">
        <el-card v-show="drugshow">
          <p class="card-title">Reactome Pathway</p>
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
        </el-card>
      </div>
    </div>

    <br />
    <div class="textitem">
      <div class="tablewidth">
        <el-card v-show="drugshow">
          <p class="card-title">Drug-Gene Interaction</p>
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
      getdetailgene: "m6a2target/api/getdetailgene",
      detailgene: [],
      werdetailgene: [],
      detailload: true,
      targetshow: false,
      wershow: false,
      tableData: [],
      drugshow: false,
    };
  },

  methods: {
    getdatagene() {
      this.detailload = false;
      this.$http
        .get(this.getdetailgene, {
          params: {
            species: "Human",
            wername: this.seargene,
            targetgene: this.seargene,
          },
        })
        .then((res) => {
          (this.werdetailgene = res.data.werdatasetinfo),
            (this.detailload = false);
          if (this.werdetailgene.length != 0) {
            this.wershow = true;
          }
        });
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
