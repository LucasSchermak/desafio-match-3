using System;
using System.Collections.Generic;
using DG.Tweening;
using Gazeus.DesafioMatch3.Core;
using Gazeus.DesafioMatch3.Models;
using Gazeus.DesafioMatch3.Views;
using TMPro;
using UnityEngine;

namespace Gazeus.DesafioMatch3.Controllers
{
    public class GameController : MonoBehaviour
    {
        [SerializeField] private BoardView _boardView;
        [SerializeField] private int _boardHeight = 10;
        [SerializeField] private int _boardWidth = 10;
        [SerializeField] private int _score = 0;
        [SerializeField] private TextMeshProUGUI _scoreText;
        [SerializeField] private GameObject _scoreParticle;

        private GameService _gameEngine;
        private bool _isAnimating;
        private int _selectedX = -1;
        private int _selectedY = -1;
        private int _lastSelectedX = -1;
        private int _lastSelectedY = -1;
        

        #region Unity
        private void Awake()
        {
            _gameEngine = new GameService();
            _boardView.TileClicked += OnTileClick;
        }

        private void OnDestroy()
        {
            _boardView.TileClicked -= OnTileClick;
        }

        private void Start()
        {
            List<List<Tile>> board = _gameEngine.StartGame(_boardWidth, _boardHeight);
            _boardView.CreateBoard(board);
        }
        #endregion

        private void AnimateBoard(List<BoardSequence> boardSequences, int index, Action onComplete)
        {
            BoardSequence boardSequence = boardSequences[index];
            
            _score += boardSequence.MatchedPosition.Count;
            UpdateScoreUI();

            Sequence sequence = DOTween.Sequence();
            sequence.Append(_boardView.DestroyTiles(boardSequence.MatchedPosition));
            sequence.Append(_boardView.MoveTiles(boardSequence.MovedTiles));
            sequence.Append(_boardView.CreateTile(boardSequence.AddedTiles));

            index += 1;
            if (index < boardSequences.Count)
            {
                sequence.onComplete += () => AnimateBoard(boardSequences, index, onComplete);
            }
            else
            {
                sequence.onComplete += () => onComplete();
            }
        }

        private void OnTileClick(int x, int y)
        {
            
            if (_isAnimating) return;
            
            _boardView.AnimateTileSelection(x, y);
            _boardView.PulseAnimation(x, y,1);
            
            if (_selectedX > -1 && _selectedY > -1)
            {
                if (Mathf.Abs(_selectedX - x) + Mathf.Abs(_selectedY - y) > 1)
                {
                    _boardView.PulseAnimation(_selectedX, _selectedY, 0);
                    _boardView.PulseAnimation(x, y,0);
                    _selectedX = -1;
                    _selectedY = -1;
                }
                else
                {
                    _boardView.PulseAnimation(x, y, 0);
                    _boardView.PulseAnimation(_selectedX, _selectedY, 0);
                    _isAnimating = true;
                    _boardView.SwapTiles(_selectedX, _selectedY, x, y).onComplete += () =>
                    {
                        bool isValid = _gameEngine.IsValidMovement(_selectedX, _selectedY, x, y);
                        if (isValid)
                        {

                            List<BoardSequence> swapResult = _gameEngine.SwapTile(_selectedX, _selectedY, x, y);
                            AnimateBoard(swapResult, 0, () => _isAnimating = false);
                        }
                        else
                        {
                            _boardView.SwapTiles(x, y, _selectedX, _selectedY).onComplete += () =>
                            {

                                _isAnimating = false;
                            };
                        }
                        _selectedX = -1;
                        _selectedY = -1;
                    };
                }
            }
            else
            {
                if (_lastSelectedX != -1 && _lastSelectedY != -1)
                {
                    _boardView.PulseAnimation(_lastSelectedX, _lastSelectedY, 0);
                }

                _lastSelectedX = _selectedX;
                _lastSelectedY = _selectedY;
                
                _selectedX = x;
                _selectedY = y;
            }
        }
        private void UpdateScoreUI()
        {
            _scoreText.transform.localScale = Vector3.one;
            Vector3 particlePosition = _scoreText.transform.position;
                
            _scoreText.text = $"Score: {_score}";
            
            _scoreText.transform.DOScale(Vector3.one * 1.2f, 0.1f) .SetLoops(2, LoopType.Yoyo);
            GameObject particleInstance = Instantiate(_scoreParticle, particlePosition, Quaternion.identity);
            
            Destroy(particleInstance, 0.8f);
                
            
        }
    }
}
