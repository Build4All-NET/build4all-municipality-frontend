import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/features/citizen/ai_chat/data/services/ai_chat_service.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import '../cubit/ai_chat_cubit.dart';
import '../cubit/ai_chat_state.dart';

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AiChatCubit(AiChatService()),
      child: const _AiChatView(),
    );
  }
}

class _AiChatView extends StatefulWidget {
  const _AiChatView();

  @override
  State<_AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<_AiChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _hasShownWelcome = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final lang = Localizations.localeOf(context).languageCode;
    _controller.clear();
    context.read<AiChatCubit>().sendMessage(text, lang);
    _scrollToBottom();
  }

  void _clearConversation(BuildContext context, AppLocalizations loc) {
    context.read<AiChatCubit>().clearConversation();
    setState(() => _hasShownWelcome = false);
    AppToast.show(context, message: loc.aiChatCleared, type: AppToastType.info);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: colors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text(loc.aiChatTitle),
          ],
        ),
        actions: [
          BlocBuilder<AiChatCubit, AiChatState>(
            builder: (context, state) {
              if (state.messages.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: loc.aiChatClear,
                onPressed: () => _clearConversation(context, loc),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<AiChatCubit, AiChatState>(
              listener: (context, state) {
                if (state.status == AiChatStatus.error && state.error != null) {
                  AppToast.show(context, message: loc.aiChatError, type: AppToastType.error);
                }
                if (state.messages.isNotEmpty) _scrollToBottom();
              },
              builder: (context, state) {
                final messages = state.messages;

                if (messages.isEmpty) {
                  return _EmptyState(loc: loc, colors: colors, theme: theme);
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length + (state.status == AiChatStatus.sending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return _TypingIndicator(colors: colors, loc: loc);
                    }
                    final msg = messages[index];
                    return _ChatBubble(
                      message: msg,
                      colors: colors,
                      theme: theme,
                      isRtl: isRtl,
                    );
                  },
                );
              },
            ),
          ),
          _InputBar(
            controller: _controller,
            loc: loc,
            colors: colors,
            theme: theme,
            onSend: () => _send(context),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations loc;
  final ColorScheme colors;
  final ThemeData theme;

  const _EmptyState({
    required this.loc,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_outlined,
                  color: colors.primary, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              loc.aiChatTitle,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              loc.aiChatEmptyHint,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colors.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final AiChatMessage message;
  final ColorScheme colors;
  final ThemeData theme;
  final bool isRtl;

  const _ChatBubble({
    required this.message,
    required this.colors,
    required this.theme,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.auto_awesome, color: colors.primary, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? colors.primary : colors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUser
                      ? colors.onPrimary
                      : colors.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final ColorScheme colors;
  final AppLocalizations loc;

  const _TypingIndicator({required this.colors, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, color: colors.primary, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  loc.aiChatSending,
                  style: TextStyle(
                    color: colors.outline,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations loc;
  final ColorScheme colors;
  final ThemeData theme;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.loc,
    required this.colors,
    required this.theme,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outline.withOpacity(0.12)),
        ),
      ),
      child: BlocBuilder<AiChatCubit, AiChatState>(
        builder: (context, state) {
          final isSending = state.status == AiChatStatus.sending;
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !isSending,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: loc.aiChatHint,
                    hintStyle: TextStyle(color: colors.outline),
                    filled: true,
                    fillColor: colors.surfaceVariant.withOpacity(0.6),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSending
                      ? colors.primary.withOpacity(0.4)
                      : colors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  color: colors.onPrimary,
                  onPressed: isSending ? null : onSend,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
