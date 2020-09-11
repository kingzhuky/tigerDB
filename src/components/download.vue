<template>
  <div class="outside">
    <el-table :data="validationData" max-height="620" stripe border style="width: 100%">
      <el-table-column property="Species" align="center" label="Species"></el-table-column>

      <el-table-column property="Assembly" align="center" label="Genome Assembly"></el-table-column>

      <el-table-column property="Data" label="Data type" align="center"></el-table-column>

      <el-table-column label="File" align="center">
        <template slot-scope="scope">
          <el-button
            type="primary"
            plain
            icon="el-icon-download"
            @click="handleEdit(scope.$index, scope.row.file)"
          >Download</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>


<script>
export default {
  data() {
    return {
      validationData: [
        {
          id: "1",
          Species: "Human",
          Assembly: "hg38",
          Data: "Validated Target",
          file: "validation_human_download.zip",
        },
        {
          id: "2",
          Species: "Human",
          Assembly: "hg38",
          Data: "Potential Target (Binding)",
          file: "binding_human_download.zip",
        },
        {
          id: "3",
          Species: "Human",
          Assembly: "hg38",
          Data: "Potential Target (Perturbation)",
          file: "perturbated_human_download.zip",
        },
        {
          id: "4",
          Species: "Mouse",
          Assembly: "mm10",
          Data: "Validated Target",
          file: "validation_human_download.zip",
        },
        {
          id: "5",
          Species: "Mouse",
          Assembly: "mm10",
          Data: "Potential Target (Binding)",
          file: "binding_mouse_download.zip",
        },
        {
          id: "6",
          Species: "Mouse",
          Assembly: "mm10",
          Data: "Potential Target (Perturbation)",
          file: "perturbated_mouse_download.zip",
        },
      ],
    };
  },
  methods: {
    handleEdit(index, file) {
      window.open("/igvurl/m6a2target/downloadfile/" + file);
    },
  },
  components: {},
};
</script>

<style>
</style>
