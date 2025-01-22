using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace Gazeus.DesafioMatch3
{
    public class SpriteLocalCoord : MonoBehaviour
    {
        
        private Image spriteImage;
        
        void Start() {
            spriteImage = GetComponent<Image>();

            Sprite sprite = spriteImage.sprite;
            Rect rect = sprite.textureRect;
            
            Vector2 texelSize = sprite.texture.texelSize;
            Vector4 uvRemap = new (
                rect.x * texelSize.x,
                rect.y * texelSize.y,
                rect.width * texelSize.x,
                rect.height * texelSize.y
            );
                spriteImage.material.SetVector("_Rect", uvRemap);
        }
    }
}
