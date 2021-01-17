import 'package:bytebank_v2/components/container.dart';
import 'package:bytebank_v2/components/error.dart';
import 'package:bytebank_v2/components/progress.dart';
import 'package:bytebank_v2/http/webclients/i18n_webclient.dart';
import 'package:bytebank_v2/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocalizationContainer extends BlocContainer {
  final Widget child;

  LocalizationContainer({@required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CurrentLocaleCubit>(
      create: (context) => CurrentLocaleCubit(),
      child: this.child,
    );
  }
}

class CurrentLocaleCubit extends Cubit<String> {
  CurrentLocaleCubit() : super("en");
}

class ViewI18n {
  String _language;

  ViewI18n(BuildContext context) {
    this._language = BlocProvider.of<CurrentLocaleCubit>(context).state;
  }

  String localize(Map<String, String> values) {
    assert(values != null);
    assert(values.containsKey(_language) != null);

    return values[_language];
  }
}

@immutable
abstract class I18NMessagesState {
  const I18NMessagesState();
}

@immutable
class InitI18NMessageState extends I18NMessagesState {
  const InitI18NMessageState();
}

@immutable
class LoadingI18NMessageState extends I18NMessagesState {
  const LoadingI18NMessageState();
}

@immutable
class LoadedI18NMessageState extends I18NMessagesState {
  final I18NMessages _messages;

  const LoadedI18NMessageState(this._messages);
}

class I18NMessages {
  final Map<String, dynamic> _messages;

  I18NMessages(this._messages);

  String get(String key) {
    assert(key != null);
    assert(_messages.containsKey(key));

    return _messages[key];
  }
}

class I18NLoadingView extends StatelessWidget {
  final I18NWidgetCreator _creator;

  I18NLoadingView(this._creator);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<I18NMessagesCubit, I18NMessagesState>(
        builder: (cotext, state) {
      if (state is InitI18NMessageState || state is LoadingI18NMessageState) {
        return ProgressView(message: 'Loading...');
      }
      if (state is LoadedI18NMessageState) {
        final messages = state._messages;
        return _creator(messages);
      }
      return ErrorView("Error search message the screen");
    });
  }
}

class I18NMessagesCubit extends Cubit<I18NMessagesState> {
  I18NMessagesCubit() : super(InitI18NMessageState());

  Future<void> reload(I18nWebClient client) async {
    emit(LoadingI18NMessageState());

    await Future.delayed(Duration(seconds: 3));
    var response = await client.findAll();

    emit(LoadedI18NMessageState(I18NMessages(response)));
  }
}

typedef Widget I18NWidgetCreator(I18NMessages messages);

class I18NLoadingContainer extends BlocContainer {
  final I18NWidgetCreator _creator;

  I18NLoadingContainer(this._creator);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<I18NMessagesCubit>(
      create: (BuildContext context) {
        final cubit = I18NMessagesCubit();
        cubit.reload(I18nWebClient());
        return cubit;
      },
      child: I18NLoadingView(this._creator),
    );
  }
}