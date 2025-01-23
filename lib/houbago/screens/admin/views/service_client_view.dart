import 'package:flutter/material.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/models/support_request.dart';
import 'package:houbago/houbago/houbago_theme.dart';
import 'package:just_audio/just_audio.dart';

class ServiceClientView extends StatefulWidget {
  const ServiceClientView({super.key});

  @override
  State<ServiceClientView> createState() => _ServiceClientViewState();
}

class _ServiceClientViewState extends State<ServiceClientView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingUrl;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    try {
      if (_currentlyPlayingUrl == url && _audioPlayer.playing) {
        await _audioPlayer.stop();
        setState(() => _currentlyPlayingUrl = null);
        return;
      }

      setState(() => _currentlyPlayingUrl = url);
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() => _currentlyPlayingUrl = null);
        }
      });
    } catch (e) {
      print('Erreur lors de la lecture audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la lecture: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showResponseDialog(BuildContext context, SupportRequest request) async {
    final TextEditingController responseController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Répondre à ${request.subject}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Message du client:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(request.message),
              if (request.audioUrl != null) ...[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: Icon(
                    _currentlyPlayingUrl == request.audioUrl
                        ? Icons.stop
                        : Icons.play_arrow,
                  ),
                  label: Text(
                    _currentlyPlayingUrl == request.audioUrl
                        ? 'Arrêter'
                        : 'Écouter le message vocal',
                  ),
                  onPressed: () => _playAudio(request.audioUrl!),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: responseController,
                decoration: const InputDecoration(
                  labelText: 'Votre réponse',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HoubagoTheme.primary,
              ),
              child: const Text('Envoyer'),
              onPressed: () async {
                if (responseController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez entrer une réponse'),
                    ),
                  );
                  return;
                }

                await DatabaseService.updateSupportRequest(
                  request.id,
                  status: 'resolved',
                  adminResponse: responseController.text.trim(),
                );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Réponse envoyée avec succès'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SupportRequest>>(
      stream: DatabaseService.getSupportRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!;
        
        if (requests.isEmpty) {
          return const Center(
            child: Text('Aucune demande de support en attente'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final bool isPending = request.status == 'pending';

            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      request.subject,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Le ${request.createdAt.toLocal().toString().split('.')[0]}',
                    ),
                    trailing: isPending
                        ? ElevatedButton.icon(
                            icon: const Icon(Icons.reply),
                            label: const Text('Répondre'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HoubagoTheme.primary,
                            ),
                            onPressed: () => _showResponseDialog(context, request),
                          )
                        : const Icon(Icons.check_circle, color: Colors.green),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (request.senderName?.isNotEmpty == true || request.senderPhone?.isNotEmpty == true) ...[
                          Text(
                            'De:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (request.senderName?.isNotEmpty == true)
                            Text('Nom: ${request.senderName!}'),
                          if (request.senderPhone?.isNotEmpty == true)
                            Text('Tél: ${request.senderPhone!}'),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          'Message:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(request.message),
                        if (request.audioUrl != null) ...[
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: Icon(
                              _currentlyPlayingUrl == request.audioUrl
                                  ? Icons.stop
                                  : Icons.play_arrow,
                            ),
                            label: Text(
                              _currentlyPlayingUrl == request.audioUrl
                                  ? 'Arrêter'
                                  : 'Écouter le message vocal',
                            ),
                            onPressed: () => _playAudio(request.audioUrl!),
                          ),
                        ],
                        if (!isPending && request.adminResponse != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Réponse:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(request.adminResponse!),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
