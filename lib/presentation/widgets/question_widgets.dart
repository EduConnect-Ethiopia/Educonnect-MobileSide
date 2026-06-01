import 'package:flutter/material.dart';

import '../../domain/entities/assessment.dart';

class QuestionWidget extends StatefulWidget {
  const QuestionWidget({
    required this.question,
    required this.onAnswer,
    this.initialAnswer,
    super.key,
  });

  final Question question;
  final void Function(dynamic answer) onAnswer;
  final dynamic initialAnswer;

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.question.text,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          _buildAnswerInput(),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    switch (widget.question.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoice();
      case QuestionType.multipleSelect:
        return _buildMultipleSelect();
      case QuestionType.trueFalse:
        return _buildTrueFalse();
      case QuestionType.fillBlank:
        return _buildFillBlank();
      case QuestionType.essay:
        return _buildEssay();
    }
  }

  Widget _buildMultipleChoice() {
    final groupValue = widget.initialAnswer as int?;
    return RadioGroup<int>(
      groupValue: groupValue,
      onChanged: (value) => widget.onAnswer(value),
      child: Column(
        children: List.generate(widget.question.options.length, (index) {
          return RadioListTile<int>(
            value: index,
            title: Text(widget.question.options[index]),
          );
        }),
      ),
    );
  }

  Widget _buildMultipleSelect() {
    final selected = (widget.initialAnswer as List<int>?) ?? <int>[];
    return Column(
      children: List.generate(widget.question.options.length, (index) {
        return CheckboxListTile(
          value: selected.contains(index),
          onChanged: (checked) {
            final updated = List<int>.from(selected);
            if (checked == true) {
              updated.add(index);
            } else {
              updated.remove(index);
            }
            widget.onAnswer(updated);
          },
          title: Text(widget.question.options[index]),
        );
      }),
    );
  }

  Widget _buildTrueFalse() {
    return _buildMultipleChoice();
  }

  Widget _buildFillBlank() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Your answer',
      ),
      controller: TextEditingController(
        text: widget.initialAnswer?.toString() ?? '',
      ),
      onChanged: widget.onAnswer,
    );
  }

  Widget _buildEssay() {
    return TextField(
      maxLines: 6,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Write your answer (min. 20 characters)',
      ),
      controller: TextEditingController(
        text: widget.initialAnswer?.toString() ?? '',
      ),
      onChanged: widget.onAnswer,
    );
  }
}
