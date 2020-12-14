<template>
    <div>
    <el-row id="readme">Readme:</el-row>
    <el-card id="readmeCard">
    1. Input genes to analyze the immune signature of pan-cancer species.
    <br />2. Correlation heat map shows the correlation between user-defined genes between pan-cancer species and immune signatures.
    <br />3. Click the correlation heatmap to display the detailed correlation scatter plot.
    </el-card>
    <el-row>
        <el-col push="4" span="8">
            <el-upload
            class="upload-demo"
            action="https://jsonplaceholder.typicode.com/posts/"
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            :before-remove="beforeRemove"
            multiple
            :limit="3"
            :on-exceed="handleExceed"
            :file-list="fileList">
            <el-button id="immusignatureplot">Upload Expression Matrix</el-button>
            <!-- <div slot="tip" class="el-upload__tip">Upload expression matrix</div> -->
            </el-upload>
        </el-col>
        <el-col push="10" span="4">
            <el-button  size="small" type="success">Example</el-button>
        </el-col>

    </el-row>
    </div>
</template>


<script>
  export default {
    data() {
      return {
        fileList: [],
      };
    },
    methods: {
      handleRemove(file, fileList) {
        console.log(file, fileList);
      },
      handlePreview(file) {
        console.log(file);
      },
      handleExceed(files, fileList) {
        this.$message.warning(`当前限制选择 3 个文件，本次选择了 ${files.length} 个文件，共选择了 ${files.length + fileList.length} 个文件`);
      },
      beforeRemove(file, fileList) {
        return this.$confirm(`确定移除 ${ file.name }？`);
      }
    }
  }
</script>

<style>
#immusignatureplot {
  width: 100%;
  background-color: rgb(20, 146, 140) !important;
  color: white;
  font-weight: bold;
}
</style>