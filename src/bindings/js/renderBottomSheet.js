import React from 'react';
import {BottomSheetBackdrop} from '@gorhom/bottom-sheet';

const renderBottomSheet = (appearsOnIndex, disappearsOnIndex) => props => {
  return React.createElement(BottomSheetBackdrop, {
    ...props,
    disappearsOnIndex,
    appearsOnIndex,
  });
};

export default renderBottomSheet;
