%% prework
mnist = data_reader('data');

%% parameters
lr = 2e-4;
batch_size = 64;
train_step = 4000;
n_display = 100;
weight_decay = 0.01;

%% model 1cnn+2fc
conv_layer1 = iconv2d(5, 5, 1, 6, 'tanh');
pooling_layer = ipooling(2, 2);
flatten_layer = iflatten();
fully_layer1 = ifc(12*12*6, 128);
dropout_layer = idropout(0.5);
fully_layer2 = ifc(128, 10);
softmax_layer = isoftmax();


%% train
%test_images = mnist.test.images;
%test_labels = mnist.test.labels;

for step = 1:train_step
    [train_images, train_labels] = mnist.train.next_batch(batch_size);
    y_conv1 = conv_layer1.forward(train_images);
    y_pool = pooling_layer.forward(y_conv1);
    y_flatten = flatten_layer.forward(y_pool);
    y_fc1 = fully_layer1.forward(y_flatten);
    y_drop = dropout_layer.forward(y_fc1);
    y_fc2 = fully_layer2.forward(y_drop);
    y = softmax_layer.forward(y_fc2);

    delta_y_fc2 = softmax_layer.backward(y, train_labels, weight_decay);
    delta_y_drop = fully_layer2.backward(delta_y_fc2, lr);
    delta_y_fc1 = dropout_layer.backward(delta_y_drop);
    delta_y_flatten = fully_layer1.backward(delta_y_fc1, lr);
    delta_y_pool = flatten_layer.backward(delta_y_flatten);
    delta_y_conv1 = pooling_layer.backward(delta_y_pool);
    [~] = conv_layer1.backward(delta_y_conv1, lr);
    
    if rem(step, n_display) == 0
        train_loss = iCrossEntropyLoss(y, train_labels, weight_decay);
        train_accuracy = iAccuracy(y, train_labels);
        fprintf('<train step: %5d> train_accuracy: %.6f, train_loss: %.6f\n', ...
            step, train_accuracy, train_loss);
        
        [test_images, test_labels] = mnist.train.next_batch(batch_size); % test
        y_conv1 = conv_layer1.forward(test_images);
        y_pool = pooling_layer.forward(y_conv1);
        y_flatten = flatten_layer.forward(y_pool);
        y_fc1 = fully_layer1.forward(y_flatten);
        y_drop = dropout_layer.forward(y_fc1);
        y_fc2 = fully_layer2.forward(y_drop);
        y = softmax_layer.forward(y_fc2);
        test_loss = iCrossEntropyLoss(y, test_labels, weight_decay);
        test_accuracy = iAccuracy(y, test_labels);
        fprintf('                    test_accuracy:  %.6f, test_loss:  %.6f\n', ...
            test_accuracy, test_loss);
    end
end
