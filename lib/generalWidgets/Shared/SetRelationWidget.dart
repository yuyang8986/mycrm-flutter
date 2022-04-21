import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mycrm/GeneralWidgets/MultilineTextFixedWidthWidget.dart';
import 'package:mycrm/Http/Repos/Company/CompanyRepo.dart';
import 'package:mycrm/Http/Repos/People/PeopleRepo.dart';
import 'package:mycrm/Http/Repos/Pipeline/PipelineRepo.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart';
import 'package:mycrm/Models/Core/Pipeline/Pipeline.dart';
import 'package:mycrm/Models/Core/contact/Company.dart';
import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:mycrm/Styles/TextStyles.dart';
import 'package:mycrm/generalWidgets/ModalBottomSheetListViewBuilder.dart';
import 'package:mycrm/generalWidgets/RemoveBinIconButton.dart';

enum SetRelationOption { pipeline, people, company }

class SetRelationWidget extends StatefulWidget {
  final Function onSelectCallBack;
  final Function removeSelectedCallBack;
  final SetRelationOption setRelationOption;
  final People selectedPeople;
  final Company selectedCompany;
  final Pipeline selectedPipeline;
  
  final Widget noDataDisplay;
  SetRelationWidget(this.setRelationOption, this.onSelectCallBack,
      this.removeSelectedCallBack,
      {this.selectedPeople,
      this.selectedCompany,
      this.selectedPipeline,
      this.noDataDisplay});
  @override
  _SetRelationWidgetState createState() => _SetRelationWidgetState();
}

class _SetRelationWidgetState extends State<SetRelationWidget> {
  var allModelsFuture;
  var setClickText = "";
  Icon icon;
  var displayInfoWidgets;
  var selectedModel;
  Color setWidgetContainerColor;

  setDisplayBasedOnModel() {
    switch (widget.setRelationOption) {
      case SetRelationOption.pipeline:
        setClickText = "Set Deal";
        allModelsFuture = allModelsFuture ??
            PipelineRepo().getAllPipelinesForCurrentEmployee();
        selectedModel = selectedModel ?? widget.selectedPipeline;
        icon = Icon(
          FontAwesomeIcons.handsHelping,
          size: ScreenUtil().setWidth(50),
          color: Colors.white,
        );
        displayInfoWidgets =
            selectedPipelineInfo(widget.selectedPipeline ?? selectedModel);
        setWidgetContainerColor = Theme.of(context).primaryColor;
        break;
      case SetRelationOption.people:
        setClickText = "Set Person & Company";
        allModelsFuture =
            allModelsFuture ?? PeopleRepo().getAllPeoplesForCurrentEmployee();
        selectedModel = selectedModel ?? widget.selectedPeople;
        icon = Icon(
          FontAwesomeIcons.idCard,
          size: ScreenUtil().setWidth(50),
          color: Colors.white,
        );
        displayInfoWidgets =
            selectedPersonInfo(widget.selectedPeople ?? selectedModel);
        setWidgetContainerColor = Theme.of(context).primaryColor;
        break;
      case SetRelationOption.company:
        setClickText = "Set Company";
        allModelsFuture = allModelsFuture ??
            CompanyRepo().getAllCompaniesForCurrentEmployee();
        selectedModel = selectedModel ?? widget.selectedCompany;
        icon = Icon(
          FontAwesomeIcons.building,
          size: ScreenUtil().setWidth(50),
          color: Colors.white,
        );
        displayInfoWidgets = selectedCompanyInfo(
            widget.selectedCompany ?? selectedModel, widget.selectedPeople);
        setWidgetContainerColor = Theme.of(context).primaryColor;
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    setDisplayBasedOnModel();
    return setRelationContainer;
  }

  get setRelationContainer {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10),),
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
        constraints: BoxConstraints(
          minHeight: ScreenUtil().setHeight(140),
        ),
        decoration: BoxDecoration(
          color: setWidgetContainerColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          child: setModelClickOrDisplay(),
          onTap: () async {
            ModalBottomSheetListViewBuilder(allModelsFuture, context,
                    (model) async {
              await widget.onSelectCallBack(model);
              setState(() {
                selectedModel = model;
              });
            }, noDataDisplay: widget.noDataDisplay)
                .showModal();
          },
        ));
  }

  selectedPipelineInfo(selectedModel) {
    if (selectedModel is Pipeline) {
      if (selectedModel != null) {
        return <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                // constraints:
                //     BoxConstraints(maxWidth: ScreenUtil().setWidth(550)),
                child: Text(
                    selectedModel.dealName +
                        " - \$" +
                        selectedModel.dealAmount.toString(),
                    style: TextStyles.setRelationTextStyle),
              ),
              selectedModel.people == null
                  ? Text(
                      TextHelper.checkTextIfNullReturnTBD(
                        selectedModel.company?.name,
                      ),
                      style: TextStyles.setRelationTextStyle)
                  : MultilineFixedWidthWidget([
                      Text(
                          TextHelper.checkTextIfNullReturnEmpty(
                              selectedModel?.people?.name),
                          style: TextStyles.setRelationTextStyle),
                      Text(
                          TextHelper.checkTextIfNullReturnEmpty(
                              selectedModel.people?.company?.name),
                          style: TextStyles.setRelationTextStyle)
                    ])
            ],
          )
        ];
      }

      return Container();
    }
  }

  selectedPersonInfo(selectedPeople) {
    if (selectedPeople != null) {
      return <Widget>[
        MultilineFixedWidthWidget([
          Text(
              (selectedPeople?.isDeleted ?? false ? "(former) " : "") +
                  selectedPeople.name,
              style: TextStyles.setRelationTextStyle),
          TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
              (selectedPeople?.company?.isDeleted ?? false ? "(former) " : "") +
                  selectedPeople.company?.name),
          TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
              selectedPeople.phone)
        ])
      ];
    }

    return Container();
  }

  selectedCompanyInfo(selectedCompany, selectedPeople) {
    if (selectedPeople?.company != null) {
      return <Widget>[
        MultilineFixedWidthWidget([
          Text(
              (selectedPeople?.company?.isDeleted ?? false
                      ? " (former) "
                      : "") +
                  selectedPeople.company.name,
              style: TextStyles.setRelationTextStyle),
          TextHelper.checkTextIfNullOrEmptyReturnEmptyContainer(
              selectedPeople.company?.location)
        ])
      ];
    } else if (selectedCompany != null)
      return <Widget>[
        MultilineFixedWidthWidget([
          Text(
              (selectedCompany?.isDeleted ?? false ? " (former) " : "") +
                  selectedCompany.name,
              style: TextStyles.setRelationTextStyle),
          Text(
              "Location: " +
                  TextHelper.checkTextIfNullReturnTBD(selectedCompany.location),
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
        ])
      ];
    return Container();
  }

  Widget get setClickTitle {
    return Container(
        alignment: Alignment.center,
        height: ScreenUtil().setHeight(120),
        child: Text(
          setClickText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: ScreenUtil().setSp(50),
          ),
        ));
  }

  Widget get selectedModelDisplayContent {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: displayInfoWidgets),
        ),
        RemoveBinIconButton(() {
          widget.removeSelectedCallBack();
          setState(() {
            selectedModel = null;
          });
        })
      ],
    );
  }

  setModelClickOrDisplay() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          selectedModel == null ? setClickTitle : selectedModelDisplayContent
        ]);
  }
}
