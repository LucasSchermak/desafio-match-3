using UnityEngine;
using UnityEngine.EventSystems;
using DG.Tweening;

namespace Gazeus.DesafioMatch3
{
    public class ButtonAnimations : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
    {

        [SerializeField] private float _hoverScale = 1.2f;
        [SerializeField] private float _animationDuration = 0.3f;
        private Vector3 _originalScale; 

        private void Start()
        {
            _originalScale = transform.localScale;
        }

        public void OnPointerEnter(PointerEventData eventData)
        {
            transform.DOScale(_originalScale * _hoverScale, _animationDuration).SetEase(Ease.OutBack);
        }
        
        public void OnPointerExit(PointerEventData eventData)
        {
            transform.DOScale(_originalScale, _animationDuration).SetEase(Ease.InBack);
        }

    }
}
