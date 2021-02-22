import 'dart:convert';

import 'package:bottle_crm/bloc/opportunity_bloc.dart';
import 'package:bottle_crm/model/case.dart';
import 'package:bottle_crm/services/crm_services.dart';
import 'package:intl/intl.dart';

class CaseBloc {
  int _casesCount;
  List _cases = [];
  // List<Profile> _assignedUsers = [];
  List _statusObjForDropDown = [];
  List _priorityObjForDropDown = [];
  List _typeOfCaseObjForDropDown = [];
  Case _currentCase;

  Map _currentEditCase = {
    'name': "",
    'status': "",
    'priority': "",
    'type_of_case': "",
    'account': "",
    'contacts': [],
    'closed_on': "",
    'description': "",
    'assigned_to': [],
    'teams': [],
  };
  String _currentEditCaseId;

  Future fetchCases({filtersData}) async {
    Map _copyFiltersData =
        filtersData != null ? new Map.from(filtersData) : null;
    if (filtersData != null) {
      if (_copyFiltersData['account'] != null) {
        opportunityBloc.accountsList.forEach((element) {
          if (element[1] == _copyFiltersData['account']) {
            _copyFiltersData['account'] = element[0].toString();
          }
        });
      }
    }

    await CrmService().getCases(queryParams: _copyFiltersData).then((response) {
      var res = json.decode(response.body);
      _cases.clear();
      _casesCount = res['cases_count'];

      res['cases'].forEach((_case) {
        Case data = Case.fromJson(_case);
        _cases.add(data);
      });

      if (_copyFiltersData == null) {
        _statusObjForDropDown = res['status'];
        _priorityObjForDropDown = res['priority'];
        _typeOfCaseObjForDropDown = res['type_of_case'];
      }
    }).catchError((onError) {
      print("fetchCases Error >> $onError");
    });
  }

  Future deleteCase(Case data) async {
    Map result;
    await CrmService()
        .deletefromModule('cases', data.id)
        .then((response) async {
      var res = (json.decode(response.body));
      await fetchCases();
      // await dashboardBloc.fetchDashboardDetails();
      result = res;
    }).catchError((onError) {
      print("deleteCase Error >> $onError");
      result = {"status": "error", "message": "Something went wrong."};
    });
    return result;
  }

  cancelCurrentEditCase() {
    _currentEditCaseId = null;
    _currentEditCase = {
      'name': "",
      'status': "",
      'priority': "",
      'type_of_case': "",
      'account': "",
      'contacts': [],
      'closed_on': "",
      'description': "",
      'assigned_to': [],
      'teams': [],
    };
  }

  Future createCase([file]) async {
    Map result;
    Map _copyOfCurrentEditCase = Map.from(_currentEditCase);

    opportunityBloc.accountsList.forEach((element) {
      if (element[1] == _copyOfCurrentEditCase['account']) {
        _copyOfCurrentEditCase['account'] = element[0].toString();
      }
    });
    _copyOfCurrentEditCase['teams'] = (_copyOfCurrentEditCase['teams']
        .map((e) => e.toString())).toList().toString();
    _copyOfCurrentEditCase['assigned_to'] =
        (_copyOfCurrentEditCase['assigned_to'].map((e) => e.toString()))
            .toList()
            .toString();
    _copyOfCurrentEditCase['contacts'] = (_copyOfCurrentEditCase['contacts']
        .map((e) => e.toString())).toList().toString();

    if (_copyOfCurrentEditCase['closed_on'] != "") {
      _copyOfCurrentEditCase['closed_on'] = DateFormat("yyyy-MM-dd").format(
          DateFormat("dd-MM-yyyy").parse(_copyOfCurrentEditCase['closed_on']));
    }

    await CrmService()
        .createCase(_copyOfCurrentEditCase)
        .then((response) async {
      // var res = json.decode(response);  # for multipartrequest
      var res = json.decode(response.body);
      if (res["error"] == false) {
        await fetchCases();
      }
      result = res;
    }).catchError((onError) {
      print("createCases Error >> $onError");
      result = {"status": "error", "message": "Something went wrong"};
    });
    return result;
  }

  updateCurrentEditCase(Case editCase) {
    List _contacts = [];
    List _teams = [];
    List _assignedUsers = [];

    _currentEditCaseId = editCase.id.toString();
    editCase.contacts.forEach((contact) {
      _contacts.add(contact.id);
    });
    editCase.assignedTo.forEach((assignedAccount) {
      _assignedUsers.add(assignedAccount.id);
    });
    editCase.teams.forEach((team) {
      _teams.add(team.id);
    });

    _currentEditCase = {
      'name': editCase.name,
      'status': editCase.status,
      'priority': editCase.priority,
      'type_of_case': editCase.caseType,
      'account': editCase.account.name,
      'contacts': _contacts,
      'closed_on': DateFormat("dd-MM-yyyy")
          .format(DateFormat("yyyy-MM-dd").parse(editCase.closedOn)),
      'description': editCase.description,
      'assigned_to': _assignedUsers,
      'teams': _teams,
    };
  }

  Future editCase([file]) async {
    Map result;
    Map _copyOfCurrentEditCase = Map.from(_currentEditCase);

    opportunityBloc.accountsList.forEach((element) {
      if (element[1] == _copyOfCurrentEditCase['account']) {
        _copyOfCurrentEditCase['account'] = element[0].toString();
      }
    });
    _copyOfCurrentEditCase['teams'] = (_copyOfCurrentEditCase['teams']
        .map((e) => e.toString())).toList().toString();
    _copyOfCurrentEditCase['assigned_to'] =
        (_copyOfCurrentEditCase['assigned_to'].map((e) => e.toString()))
            .toList()
            .toString();
    _copyOfCurrentEditCase['contacts'] = (_copyOfCurrentEditCase['contacts']
        .map((e) => e.toString())).toList().toString();

    if (_copyOfCurrentEditCase['closed_on'] != "") {
      _copyOfCurrentEditCase['closed_on'] = DateFormat("yyyy-MM-dd").format(
          DateFormat("dd-MM-yyyy").parse(_copyOfCurrentEditCase['closed_on']));
    }

    if (_copyOfCurrentEditCase != null) {
      _copyOfCurrentEditCase
          .removeWhere((key, value) => value.runtimeType != String);
    }

    await CrmService()
        .editCase(_copyOfCurrentEditCase, _currentEditCaseId, file)
        .then((response) async {
      var res = json.decode(response.body);
      if (res["error"] == false) {
        await fetchCases();
      }
      result = res;
    }).catchError((onError) {
      print("editCase Error >> $onError");
      result = {"status": "error", "message": "Something went wrong"};
    });
    return result;
  }

  List get cases {
    return _cases;
  }

  List get statusObjForDropDown {
    return _statusObjForDropDown;
  }

  List get priorityObjForDropDown {
    return _priorityObjForDropDown;
  }

  List get typeOfCaseObjForDropDown {
    return _typeOfCaseObjForDropDown;
  }

  int get casesCount {
    return _casesCount;
  }

  Map get currentEditCase {
    return _currentEditCase;
  }

  String get currentEditCaseId {
    return _currentEditCaseId;
  }

  set currentEditCaseId(id) {
    _currentEditCaseId = id;
  }

  Case get currentCase {
    return _currentCase;
  }

  set currentCase(data) {
    _currentCase = data;
  }
}

final caseBloc = CaseBloc();
