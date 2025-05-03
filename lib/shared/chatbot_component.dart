import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/chat_utils.dart';
import 'chat_suggestions.dart';
import 'package:flutter/services.dart';

// Chatbot-related variables and methods
class ChatbotComponent {
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isChatLoading = false;
  bool _isDeepMindMode = false;

  // Predefined questions and answers
  static final List<Map<String, String>> _predefinedQA = [
    // Academic and Profile
    {
      'question': 'How do I find a mentor?',
      'answer':
          'To find a mentor, navigate to the "Mentorship" section from the main menu. There you can browse available mentors based on industry, expertise, or location. You can send a mentor request after reviewing their profile.'
    },
    {
      'question': 'Where can I see job postings?',
      'answer':
          'Job postings can be found in the "Career" tab. You can filter jobs by industry, location, and experience level. Alumni can also post job opportunities for fellow graduates.'
    },
    {
      'question': 'How to update my profile?',
      'answer':
          'To update your profile, go to the "Profile" section and click on "Edit Profile". You can update your personal information, work experience, education details, and upload a new profile picture.'
    },
    {
      'question': 'How to connect with other alumni?',
      'answer':
          'You can connect with other alumni through the "Network" section. Search for alumni by name, graduation year, or industry. You can also join alumni groups based on shared interests or graduation years.'
    },

    // General greetings
    {
      'question': 'hi',
      'answer': 'Hello! How can I assist you today with AlumniConnect?'
    },
    {
      'question': 'hello',
      'answer': 'Hi there! Welcome to AlumniConnect. How can I help you?'
    },
    {
      'question': 'hey',
      'answer':
          'Hey! I\'m here to help with any questions about alumni connections, job opportunities, or events.'
    },

    // Events and Activities
    {
      'question': 'How do I register for alumni events?',
      'answer':
          'To register for alumni events, navigate to the "Events" section in the More menu. Browse upcoming events, click on any event you\'re interested in, and press the "Register" button. You\'ll receive a confirmation email after successful registration.'
    },
    {
      'question': 'Are there any upcoming alumni meetups?',
      'answer':
          'Yes! You can find all upcoming alumni meetups in the "Events" section. The next major event is Alumni Connect 2023 on October 15, 2023, at the Main Auditorium. There\'s also a virtual Career Fair scheduled for November 10.'
    },

    // Career and Professional Development
    {
      'question': 'How can alumni help with my career?',
      'answer':
          'Alumni can support your career in many ways: mentorship, job referrals, internship opportunities, and professional advice. Use the "Connect" section to find alumni in your field of interest and reach out to them directly or through our mentorship program.'
    },
    {
      'question': 'Are there any internship opportunities?',
      'answer':
          'Yes, internship opportunities are posted in the "Jobs & Internships" section under the More menu. Alumni regularly post internship opportunities for current students. You can filter internships by department, duration, and whether they are paid or unpaid.'
    },
    {
      'question': 'How do I apply for jobs through the platform?',
      'answer':
          'To apply for jobs, go to "Jobs & Internships" in the More menu, browse available positions, and click "Apply" on jobs you\'re interested in. You\'ll need to have your resume uploaded to your profile. Some positions may redirect you to the employer\'s website to complete the application.'
    },

    // Mentoring and Guidance
    {
      'question': 'What is the mentorship program?',
      'answer':
          'The mentorship program connects current students with alumni mentors in their field of interest. Mentors provide career guidance, industry insights, and professional development advice. Applications for the program are currently open until September 30, 2023.'
    },
    {
      'question': 'How long does the mentoring program last?',
      'answer':
          'The formal mentoring program lasts for 6 months, but many mentor-mentee relationships continue informally beyond this period. During the program, you\'ll have structured check-ins and goals to achieve with your mentor.'
    },

    // App Navigation and Features
    {
      'question': 'How do I use the discussion forum?',
      'answer':
          'The discussion forum can be accessed from the bottom navigation bar. You can browse existing discussions by topic, create new discussion threads, and contribute to ongoing conversations. Be respectful of community guidelines when posting.'
    },
    {
      'question': 'What information can I see about alumni?',
      'answer':
          'You can view alumni profiles that include their name, graduation year, current company, department of study, contact information (if they\'ve made it public), and social media links. Some alumni also share their professional achievements and areas of expertise.'
    },
    {
      'question': 'How do I message an alumnus?',
      'answer':
          'To message an alumnus, go to their profile through the "Connect" section, and click on the "Message" button. Your message will be sent to their email address. Some alumni also provide direct contact methods like LinkedIn profiles.'
    },

    // About the Platform
    {
      'question': 'What is AlumniConnect?',
      'answer':
          'AlumniConnect is a platform that bridges current students and alumni. It offers networking opportunities, mentorship programs, job postings, discussion forums, and events to strengthen the alumni community and provide value to both current students and graduates.'
    },
    {
      'question': 'Who can join AlumniConnect?',
      'answer':
          'AlumniConnect is available to all current students, graduates, and faculty members of the institution. Students get access automatically with their academic credentials, while alumni can sign up using their graduation details for verification.'
    },

    // Seeking Help
    {
      'question': 'How can I report an issue?',
      'answer':
          'To report an issue with the platform, go to the More section and click on "Help & Support." From there, you can submit a detailed description of the problem you\'re experiencing. Our support team will get back to you within 48 hours.'
    },
    {
      'question': 'I forgot my password',
      'answer':
          'If you\'ve forgotten your password, click on "Forgot Password" on the login screen. Enter your registered email address, and we\'ll send you a link to reset your password. Check your spam folder if you don\'t receive the email within a few minutes.'
    },

    // General Help
    {
      'question': 'thanks',
      'answer':
          'You\'re welcome! Feel free to ask if you have any other questions about AlumniConnect.'
    },
    {
      'question': 'thank you',
      'answer':
          'You\'re very welcome! Is there anything else I can help you with today?'
    },
    {
      'question': 'bye',
      'answer':
          'Goodbye! Feel free to return if you have more questions about AlumniConnect.'
    }
  ];

  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
  }

  Future<void> _sendChatMessage(String message, Function setState) async {
    if (message.isEmpty) return;

    setState(() {
      _chatMessages.add({'role': 'user', 'message': message});
      _isChatLoading = true;
    });

    // Scroll to the bottom after adding user message
    _scrollToBottom();

    // Check if the message matches any predefined questions
    final predefinedAnswer = _getPredefinedAnswer(message);
    if (predefinedAnswer != null && !_isDeepMindMode) {
      // Add a slight random delay to make it feel more natural
      await Future.delayed(
          Duration(milliseconds: 500 + (200 * (message.length / 20)).round()));

      setState(() {
        _chatMessages.add({'role': 'bot', 'message': predefinedAnswer});
        _isChatLoading = false;
      });

      // Scroll to the bottom after bot responds
      _scrollToBottom();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final reply = responseData['reply'];
        setState(() {
          _chatMessages.add({'role': 'bot', 'message': reply});
        });
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      setState(() {
        _chatMessages.add(
            {'role': 'bot', 'message': 'Error: Unable to fetch response.'});
      });
    } finally {
      setState(() {
        _isChatLoading = false;
      });

      // Scroll to bottom after receiving response
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  String? _getPredefinedAnswer(String question) {
    // First try exact match (case-insensitive)
    question = question.trim().toLowerCase();

    // Check for exact matches
    for (var qa in _predefinedQA) {
      if (qa['question']!.toLowerCase() == question) {
        return qa['answer'];
      }
    }

    // If no exact match, try fuzzy matching
    return ChatUtils.findBestMatchingAnswer(_predefinedQA, question);
  }

  List<String> _getSuggestedQuestions(String input) {
    if (input.isEmpty) {
      return []; // No suggestions for empty input
    }

    input = input.toLowerCase().trim();
    List<String> suggestions = [];

    for (var qa in _predefinedQA) {
      String question = qa['question']!;
      // Add if the question contains the input or input contains part of the question
      if (question.toLowerCase().contains(input) ||
          (input.length > 3 &&
              ChatUtils.calculateSimilarity(question.toLowerCase(), input) >
                  0.4)) {
        if (!suggestions.contains(question) && suggestions.length < 5) {
          suggestions.add(question);
        }
      }
    }

    return suggestions;
  }

  void openChatBotDialog(BuildContext context) {
    // Reset to default mode when opening dialog
    _isDeepMindMode = false;

    // Add haptic feedback when opening dialog
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Suggestions based on current input
            List<String> suggestions =
                _getSuggestedQuestions(_chatController.text);

            // Get contextual suggestions based on last message
            Map<String, List<String>> contextualSuggestions =
                _chatMessages.isNotEmpty
                    ? ChatSuggestions.getFollowUpSuggestions(
                        _chatMessages.last['message'] ?? '')
                    : ChatSuggestions.topicSuggestions;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with flexible text
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.smart_toy_rounded,
                            color: Colors.indigo,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'AlumniConnect Assistant',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.indigo.shade800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Add spacing between title and switch
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'DeepMind',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _isDeepMindMode
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                ),
                              ),
                              Switch(
                                value: _isDeepMindMode,
                                activeColor: Colors.deepPurple,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onChanged: (value) {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _isDeepMindMode = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close, color: Colors.grey),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          // Mode indicator and clear chat button
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _isDeepMindMode
                                        ? Colors.deepPurple.withOpacity(0.1)
                                        : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: _isDeepMindMode
                                          ? Colors.deepPurple.withOpacity(0.3)
                                          : Colors.blue.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isDeepMindMode
                                            ? Icons.auto_awesome
                                            : Icons.lightbulb_outline,
                                        color: _isDeepMindMode
                                            ? Colors.deepPurple
                                            : Colors.blue,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _isDeepMindMode
                                            ? 'Advanced AI Mode'
                                            : 'Standard Mode',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: _isDeepMindMode
                                              ? Colors.deepPurple
                                              : Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    setState(() {
                                      _chatMessages.clear();
                                    });
                                  },
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: Text(
                                    'Clear chat',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // FAQ Categories in Standard Mode
                          if (!_isDeepMindMode)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade50,
                                    Colors.indigo.shade50
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.blue.shade100.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              height: 130,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber.shade600,
                                          size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Frequently Asked Questions',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.indigo.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          _buildFAQCategory(
                                              'General',
                                              [
                                                'What is AlumniConnect?',
                                                'How to update my profile?',
                                                'How do I use the discussion forum?'
                                              ],
                                              setState,
                                              constraints.maxWidth / 3),
                                          const SizedBox(width: 10),
                                          _buildFAQCategory(
                                              'Career',
                                              [
                                                'Where can I see job postings?',
                                                'Are there any internship opportunities?',
                                                'How can alumni help with my career?'
                                              ],
                                              setState,
                                              constraints.maxWidth / 3),
                                          const SizedBox(width: 10),
                                          _buildFAQCategory(
                                              'Networking',
                                              [
                                                'How do I find a mentor?',
                                                'How to connect with other alumni?',
                                                'How do I message an alumnus?'
                                              ],
                                              setState,
                                              constraints.maxWidth / 3),
                                          const SizedBox(width: 10),
                                          _buildFAQCategory(
                                              'Events',
                                              [
                                                'How do I register for alumni events?',
                                                'Are there any upcoming alumni meetups?',
                                                'What is the mentorship program?'
                                              ],
                                              setState,
                                              constraints.maxWidth / 3),
                                        ],
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),

                          // Chat Messages
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: _chatMessages.isEmpty
                                  ? Center(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.indigo.shade50,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons
                                                    .chat_bubble_outline_rounded,
                                                size: 40,
                                                color: Colors.indigo.shade400,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Ask me anything about AlumniConnect!',
                                              style: GoogleFonts.poppins(
                                                color: Colors.indigo.shade800,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 32),
                                              child: Text(
                                                'I can help you navigate the platform, find mentors, discover job opportunities, and more.',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            if (!_isDeepMindMode)
                                              Wrap(
                                                alignment: WrapAlignment.center,
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  _buildQuickStartChip(
                                                      'Find a mentor', () {
                                                    _sendChatMessage(
                                                        'How do I find a mentor?',
                                                        setState);
                                                  }),
                                                  _buildQuickStartChip(
                                                      'Job opportunities', () {
                                                    _sendChatMessage(
                                                        'Where can I see job postings?',
                                                        setState);
                                                  }),
                                                  _buildQuickStartChip(
                                                      'Update profile', () {
                                                    _sendChatMessage(
                                                        'How to update my profile?',
                                                        setState);
                                                  }),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 12),
                                      itemCount: _chatMessages.length,
                                      itemBuilder: (context, index) {
                                        final chat = _chatMessages[index];
                                        final isUser = chat['role'] == 'user';

                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            mainAxisAlignment: isUser
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              if (!isUser)
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor:
                                                      Colors.indigo.shade100,
                                                  child: Icon(
                                                    Icons.smart_toy_rounded,
                                                    color:
                                                        Colors.indigo.shade700,
                                                    size: 18,
                                                  ),
                                                ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                                  decoration: BoxDecoration(
                                                    color: isUser
                                                        ? Colors.indigo.shade500
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              16),
                                                      topRight:
                                                          const Radius.circular(
                                                              16),
                                                      bottomLeft: isUser
                                                          ? const Radius
                                                              .circular(16)
                                                          : const Radius
                                                              .circular(4),
                                                      bottomRight: isUser
                                                          ? const Radius
                                                              .circular(4)
                                                          : const Radius
                                                              .circular(16),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.1),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    chat['message']!,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: isUser
                                                          ? Colors.white
                                                          : Colors
                                                              .grey.shade800,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (isUser)
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor:
                                                      Colors.indigo.shade500,
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),

                          // Loading indicator
                          if (_isChatLoading)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.indigo.shade400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Thinking...",
                                    style: GoogleFonts.poppins(
                                      color: Colors.indigo.shade400,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Context-aware suggestions
                          if (!_isDeepMindMode &&
                              _chatMessages.isNotEmpty &&
                              !_isChatLoading)
                            Container(
                              height: 70,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'You might want to ask:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: contextualSuggestions
                                          .entries.first.value.length,
                                      itemBuilder: (context, index) {
                                        final suggestion = contextualSuggestions
                                            .entries.first.value[index];
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.indigo.shade50,
                                              foregroundColor:
                                                  Colors.indigo.shade700,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                side: BorderSide(
                                                    color:
                                                        Colors.indigo.shade200),
                                              ),
                                            ),
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              _sendChatMessage(
                                                  suggestion, setState);
                                            },
                                            child: Text(
                                              suggestion,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Search suggestions based on input
                          if (suggestions.isNotEmpty &&
                              _chatController.text.isNotEmpty)
                            Container(
                              height: 40,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: suggestions.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade100,
                                        foregroundColor: Colors.indigo,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          side: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        _chatController.text =
                                            suggestions[index];
                                        setState(() {});
                                      },
                                      child: Text(
                                        suggestions[index],
                                        style:
                                            GoogleFonts.poppins(fontSize: 12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          // Input field
                          Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _chatController,
                              onChanged: (_) =>
                                  setState(() {}), // Update for suggestions
                              decoration: InputDecoration(
                                hintText: _isDeepMindMode
                                    ? 'Ask anything with DeepMind...'
                                    : 'Type your question here...',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.message_rounded,
                                  color: Colors.indigo.shade300,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.send_rounded,
                                    color: Colors.indigo.shade400,
                                  ),
                                  onPressed: () {
                                    if (_chatController.text
                                        .trim()
                                        .isNotEmpty) {
                                      HapticFeedback.mediumImpact();
                                      _sendChatMessage(
                                          _chatController.text, setState);
                                      _chatController.clear();
                                    }
                                  },
                                ),
                              ),
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  _sendChatMessage(value, setState);
                                  _chatController.clear();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFAQCategory(String category, List<String> questions,
      Function setState, double maxWidth) {
    return Container(
      width: maxWidth.clamp(150, 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
                fontSize: 12,
              ),
            ),
          ),
          const Divider(height: 8),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _sendChatMessage(questions[index], setState);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            questions[index],
                            style: GoogleFonts.poppins(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartChip(String label, VoidCallback onTap) {
    return ActionChip(
      avatar: const Icon(
        Icons.lightbulb_outline,
        size: 16,
        color: Colors.amber,
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12),
      ),
      backgroundColor: Colors.amber.shade50,
      side: BorderSide(color: Colors.amber.shade200),
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}
