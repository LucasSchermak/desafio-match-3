using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace Gazeus.DesafioMatch3
{
    public class SceneHandler : MonoBehaviour
    {
        [SerializeField] private GameObject _particlePrefab;
        [SerializeField] private GameObject _imageTransitionPrefab;
        [SerializeField] private Canvas _canvas;

        private void Start()
        {
            Sequence sequence = DOTween.Sequence();
            GameObject image =Instantiate(_imageTransitionPrefab, Vector3.zero, Quaternion.identity,_canvas.transform );
            image.transform.localScale = Vector3.one;
            sequence.Append(image.transform.DOScale(0, 2f).SetEase(Ease.OutCubic));
            sequence.Join(image.transform.DORotate(new Vector3(0, 0, 720), 2f).SetEase(Ease.OutCubic)).onComplete =
                () =>
                {
                    Destroy(image,2f);
                };
        }

        public void SceneTransistion()
        {
            Sequence sequence = DOTween.Sequence();
            GameObject image =Instantiate(_imageTransitionPrefab, Vector3.zero, Quaternion.identity,_canvas.transform );
            image.transform.localScale = Vector3.zero;
            sequence.Append(image.transform.DOScale(1, 2f).SetEase(Ease.OutCubic));
            sequence.Join(image.transform.DORotate(new Vector3(0, 0, 720), 2f).SetEase(Ease.OutCubic)).onComplete =
                () =>
                {
                    StartGameScene();
                };
        }
        
        private void StartGameScene()
        {
            SceneManager.LoadScene(1);
        }
    }
}
