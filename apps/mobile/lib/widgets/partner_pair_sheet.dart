import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/aivo_theme.dart';
import '../models/wellness_state.dart';
import 'qr_code_widget.dart';

class PartnerPairSheet extends StatefulWidget {
  final WellnessState state;

  const PartnerPairSheet({
    super.key,
    required this.state,
  });

  @override
  State<PartnerPairSheet> createState() => _PartnerPairSheetState();
}

class _PartnerPairSheetState extends State<PartnerPairSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasCopied = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.state.currentInvite == null) {
      widget.state.generateInviteCode();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleRedeem() async {
    final code = _codeController.text.trim();
    if (code.length < 4) {
      setState(() {
        _errorMessage = 'Please enter a valid invitation code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.state.redeemInviteCode(code);
    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1E1B25),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF10B981)),
          ),
          content: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Color(0xFF34D399), size: 18),
              const SizedBox(width: 8),
              Text('Paired with ${widget.state.partnerUser.name}! ♥', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid or expired code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final invite = widget.state.currentInvite;
    final displayCode = invite?.code ?? 'SWG789';
    final deepLink = invite?.deepLink ?? 'app://swing/pair?code=$displayCode';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF131118),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 14, left: 20, right: 20, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title & Subtitle
          const Text(
            'Partner Linking & Sync',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Predictive wellness updates without sharing raw biometrics',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AivoColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          // Tab Bar
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(19),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                gradient: const LinearGradient(
                  colors: [AivoColors.orange, Color(0xFFFF5E1E)],
                ),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AivoColors.textSecondary,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Invite Partner'),
                Tab(text: 'Enter Code'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tab Views
          SizedBox(
            height: 330,
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: INVITE (QR + Code + Share)
                Column(
                  children: [
                    AivoQrCodeWidget(code: deepLink, size: 150),
                    const SizedBox(height: 16),
                    
                    // 6-digit Code Pill
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: displayCode));
                        setState(() => _hasCopied = true);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _hasCopied = false);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AivoColors.orange.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              _hasCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                              color: _hasCopied ? const Color(0xFF10B981) : AivoColors.orangeLight,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hasCopied ? 'Code copied to clipboard!' : 'Valid for 24 hours • Tap to copy',
                      style: TextStyle(
                        color: _hasCopied ? const Color(0xFF34D399) : AivoColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),

                    // Native Share Button
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: deepLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF1E1B25),
                            behavior: SnackBarBehavior.floating,
                            content: Text('Deep link copied: $deepLink'),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.share_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Share Pairing Link via Native Sheet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // TAB 2: ENTER CODE
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Enter Partner Invite Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ask your partner to share their 6-digit code or QR link',
                      style: TextStyle(
                        color: AivoColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Code input
                    Container(
                      width: 220,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AivoColors.orange.withOpacity(0.4)),
                      ),
                      child: TextField(
                        controller: _codeController,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'XYZ789',
                          hintStyle: TextStyle(color: Colors.white24, letterSpacing: 2),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                      ),
                    ],

                    const Spacer(),

                    // Connect button
                    GestureDetector(
                      onTap: _isLoading ? null : _handleRedeem,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [AivoColors.orange, Color(0xFFFF5E1E)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AivoColors.orange.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.link_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Connect with Partner',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
