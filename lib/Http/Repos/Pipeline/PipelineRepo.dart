import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:mycrm/Http/HttpRequest.dart';

import '../../../Models/Core/Pipeline/Pipeline.dart';

class PipelineRepo extends RepoBase {
  //final HttpRequest httpRequest = new HttpRequest();
  final String getAllPipelinesUrl = HttpRequest.baseUrl + 'pipeline';
  final String addPipelineUrl = HttpRequest.baseUrl + 'pipeline';

  Future<RepoResponse> getAllPipelines() async {
    print('init get all pipelines request');
    Response response = await HttpRequest.get(getAllPipelinesUrl);

    var result = await handleResponse(response);

    if (result.success) {
      var data = result.model.map((s) {
        return Pipeline.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<Pipeline>.from(data));
    }

    return RepoResponse(false, null);
  }

  Future<RepoResponse> getAllPipelinesForCurrentEmployee() async {
    print('init get all pipelines  for employee request');
    var response = await HttpRequest.get(getAllPipelinesUrl + "/employee");
    var result = await handleResponse(response);
    if (result.success) {
      var data = result.model.map((s) {
        return Pipeline.fromJson(s);
      }).toList();
      return RepoResponse(true, new List<Pipeline>.from(data));
    }

    return RepoResponse(false, null);
  }

  // Future<List<Pipeline>> getStarredPipelines() async {
  //   print('init getStarredPipelines pipelines request');
  //   var result = await httpRequest.get(getAllPipelinesUrl + "/filter?=starred");

  //   if (result.statusCode == 204) return null;
  //   var data = result.data.map((s) {
  //     return Pipeline.fromJson(s);
  //   }).toList();
  //   return new List<Pipeline>.from(data);
  // }

  // Future<List<Pipeline>> getOverduePipelines() async {
  //   print('init getStarredPipelines pipelines request');
  //   var result = await httpRequest.get(getAllPipelinesUrl + "/filter?=overdue");

  //   if (result.statusCode == 204) return null;
  //   var data = result.data.map((s) {
  //     return Pipeline.fromJson(s);
  //   }).toList();
  //   return new List<Pipeline>.from(data);
  // }

  // Future<List<Pipeline>> getFilteredPipelines(List<String> filters) async {
  //   print('init get Filtered Pipelines request');
  //   var query = '';
  //   for (var filter in filters) {
  //     query += "filter=$filter&";
  //   }
  //   var result = await httpRequest.get(getAllPipelinesUrl + "/filter?" + query);

  //   if (result.statusCode == 204) return null;
  //   var data = result.data.map((s) {
  //     return Pipeline.fromJson(s);
  //   }).toList();
  //   return new List<Pipeline>.from(data);
  // }

  Future<RepoResponse> add(Pipeline pipeline) async {
    print('init add pipeline request');
    print('request body:' + pipeline.toJson().toString());
    var response = await HttpRequest.post(addPipelineUrl, pipeline.toJson());
    var result = await handleResponse(response);
    if (result.success) {
      return RepoResponse(true, Pipeline.fromJson(result.model));
    }
    return  RepoResponse(false, null);
  }

  Future<Response> update(Pipeline pipeline) async {
    print('init put stage request');
    print('request body:' + pipeline.toJson().toString());
    return await HttpRequest.put(
        addPipelineUrl + "/${pipeline.id}", pipeline.toJson());
  }

  Future<Response> setWonLostClosed(
      String id, String stageName, Pipeline pipeline) async {
    print('init put stage request: set won/lost/closed');
    return await HttpRequest.put(
        addPipelineUrl + "/$id?stageName=$stageName", pipeline);
  }

   Future<Response> linkPerson(int personId, String pipelineId) async {
    print('init linkPerson request');
    return await HttpRequest.get(
        addPipelineUrl + "/linkperson/$pipelineId?personId=$personId");
  }


  

  Future<Response> delete(String id) async {
    print('init delete stage request');
    return await HttpRequest.delete(addPipelineUrl + "/$id");
  }

  // Future<List<Pipeline>> getPipelinesByStage(String stageName) async {
  //   print('init get all pipelines by stage request');
  //   var result =
  //       await httpRequest.get(getAllPipelinesUrl + "/stage?=$stageName");

  //   if (result.statusCode == 204) return null;
  //   var data = result.data.map((s) {
  //     return Pipeline.fromJson(s);
  //   }).toList();
  //   return new List<Pipeline>.from(data);
  // }
}
