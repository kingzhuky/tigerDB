<template>
  <div class="infor">
    <el-card v-loading="loading">
    <p class="card-title">Dataset Information</p>
    <div>
    <el-table :data="tableData" style="width: 100%" v-loading="artloading">
            <el-table-column prop="title" label width="180"></el-table-column>
            <el-table-column label>
              <template slot-scope="scope">
                <a v-html="scope.row.value"></a>
              </template>
            </el-table-column>
    </el-table>
    </div>
    </el-card>
    </div>
</template>

<script>

export default {
  name: "home",
  data: function() {
    return {
      loading: true,
      tableData: [
      ]
    };
  },

  methods: {
    //获取表格数据
    getTableData(sample) {
      this.loading = true;
      this.$http
        .get("/tiger/immunescreendetail2.php", {
          params: {
            colu:"DatasetID",
            coluvalue: sample,
            tabl: "datesetinfo"
          }
        })
        .then(res => {
          if (res.data.status === 200) {
            this.tableData = res.data.list;
            this.loading = false;
          }
        })
        .catch(error => {
          console.log(error);
        });
    }
  }

   
  
};
</script>

<style>

</style>